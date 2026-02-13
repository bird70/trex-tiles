
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.project}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "ecs_task" {
  name = "${var.project}-task-policy"
  role = aws_iam_role.ecs_task.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      : "S3ReadGeoPackage",
        Effect   : "Allow",
        Action   : ["s3:GetObject","s3:ListBucket"],
        Resource : [
          "arn:aws:s3:::${var.gpkg_bucket}",
          "arn:aws:s3:::${var.gpkg_bucket}/${var.gpkg_key}"
        ]
      },
      {
        Sid    : "SecretsManagerRead",
        Effect : "Allow",
        Action : ["secretsmanager:GetSecretValue"],
        Resource : "*"
      }
    ]
  })
}
