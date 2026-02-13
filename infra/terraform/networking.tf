
resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  vpc_id      = var.vpc_id
  description = "ALB SG"
  ingress { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_security_group" "ecs" {
  name        = "${var.project}-ecs-sg"
  vpc_id      = var.vpc_id
  description = "ECS SG"
  ingress { from_port = 6767, to_port = 6767, protocol = "tcp", security_groups = [aws_security_group.alb.id] }
  egress  { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}

# EFS only if using GeoPackage sync
resource "aws_efs_file_system" "this" {
  count = length(var.gpkg_bucket) > 0 && length(var.gpkg_key) > 0 ? 1 : 0
  creation_token  = "${var.project}-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
}

resource "aws_efs_mount_target" "mt" {
  for_each = length(var.gpkg_bucket) > 0 && length(var.gpkg_key) > 0 ? toset(var.private_subnet_ids) : []
  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id       = each.value
  security_groups = [aws_security_group.ecs.id]
}

resource "aws_efs_access_point" "data" {
  count = length(var.gpkg_bucket) > 0 && length(var.gpkg_key) > 0 ? 1 : 0
  file_system_id = aws_efs_file_system.this[0].id
  posix_user { uid = 0, gid = 0 }
  root_directory { path = "/data" creation_info { owner_uid = 0, owner_gid = 0, permissions = "0755" } }
}
