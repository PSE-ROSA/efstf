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
    Backup = "TestDaily7"
  }
}

# 启用 EFS 自动备份策略
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.example.id

  backup_policy {
    status = "ENABLED"
  }
}

# 创建安全组
# resource "aws_security_group" "efs_sg" {
#   name        = "efs-sg"
#   description = "Allow inbound traffic to EFS"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 2049
#     to_port     = 2049
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "efs-sg"
#   }
# }

# 更新现有安全组规则，允许 NFS 流量
resource "aws_security_group_rule" "allow_nfs_inbound" {
  security_group_id = var.existing_security_group_id

  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # 允许所有 IP 访问 NFS，按需调整
  description       = "Allow NFS inbound traffic for EFS"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  security_group_id = var.existing_security_group_id

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # 允许所有协议
  cidr_blocks       = ["0.0.0.0/0"] # 允许所有 IP 访问
  description       = "Allow all outbound traffic"
}

# 创建挂载目标
resource "aws_efs_mount_target" "example" {
  count         = length(var.subnet_ids)
  file_system_id = aws_efs_file_system.example.id
  subnet_id      = element(var.subnet_ids, count.index)
  # security_groups = [aws_security_group.efs_sg.id]
  security_groups = [var.existing_security_group_id] # 使用现有安全组
}