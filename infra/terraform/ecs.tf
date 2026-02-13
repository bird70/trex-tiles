
resource "aws_ecs_cluster" "this" {
  name = "${var.project}-cluster"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project}"
  retention_in_days = 14
}

locals {
  use_gpkg_sync = length(var.gpkg_bucket) > 0 && length(var.gpkg_key) > 0
}

resource "aws_ecs_task_definition" "trex" {
  family                   = "${var.project}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  dynamic "volume" {
    for_each = local.use_gpkg_sync ? [1] : []
    content {
      name = "data"
      efs_volume_configuration {
        file_system_id     = aws_efs_file_system.this[0].id
        transit_encryption = "ENABLED"
        authorization_config {
          access_point_id = aws_efs_access_point.data[0].id
          iam             = "ENABLED"
        }
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      : "trex",
      image     : var.trex_image,
      essential : true,
      portMappings : [{ containerPort: 6767, hostPort: 6767, protocol: "tcp" }],
      environment : [
        { name: "POSTGRES_URL", value: var.postgres_url },
        { name: "MINZOOM", value: tostring(var.minzoom) },
        { name: "MAXZOOM", value: tostring(var.maxzoom) }
      ],
      linuxParameters : { initProcessEnabled: true },
      logConfiguration : { logDriver: "awslogs", options: { awslogs-group: aws_cloudwatch_log_group.this.name, awslogs-region: var.region, awslogs-stream-prefix: "trex" } },
      command: ["/entrypoint.sh"],
      mountPoints : local.use_gpkg_sync ? [{ sourceVolume: "data", containerPath: "/data", readOnly: true }] : []
    },
    {
      name      : "s3sync",
      image     : var.awscli_image,
      essential : local.use_gpkg_sync ? true : false,
      command   : local.use_gpkg_sync ? [
        "sh","-c",
        "mkdir -p /data && while true; do echo $(date) syncing...; aws s3 cp s3://${var.gpkg_bucket}/${var.gpkg_key} /data/lines.gpkg --only-show-errors; sleep ${var.sync_interval_seconds}; done"
      ] : null,
      logConfiguration : { logDriver: "awslogs", options: { awslogs-group: aws_cloudwatch_log_group.this.name, awslogs-region: var.region, awslogs-stream-prefix: "s3sync" } },
      mountPoints : local.use_gpkg_sync ? [{ sourceVolume: "data", containerPath: "/data", readOnly: false }] : []
    }
  ])
}

resource "aws_security_group" "alb" { # referenced in networking.tf
  name        = "${var.project}-alb-sg"
  vpc_id      = var.vpc_id
  description = "ALB SG"
  ingress { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_lb" "this" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project}-tg"
  port        = 6767
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/", healthy_threshold = 2, unhealthy_threshold = 5, timeout = 5, interval = 30, matcher = "200-399" }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.alb_acm_certificate_arn
  default_action { type = "forward", target_group_arn = aws_lb_target_group.this.arn }
}

resource "aws_ecs_service" "trex" {
  name            = "${var.project}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.trex.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "trex"
    container_port   = 6767
  }

  depends_on = [aws_lb_listener.https]
}
