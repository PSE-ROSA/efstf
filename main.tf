# 创建 EFS 文件系统
resource "aws_efs_file_system" "example" {
  creation_token = "my-efs-token"

  # 启用加密
  encrypted = true

  # 可选配置：设置吞吐量模式和生命周期策略
  throughput_mode = "bursting"
  
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = var.efs_name
  }
}

# 创建安全组
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow inbound traffic to EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-sg"
  }
}

# 创建挂载目标
resource "aws_efs_mount_target" "example" {
  count         = length(var.subnet_ids)
  file_system_id = aws_efs_file_system.example.id
  subnet_id      = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}