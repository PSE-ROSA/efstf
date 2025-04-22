# 创建 EFS 文件系统
resource "aws_efs_file_system" "example" {
  creation_token = "my-efs-token"

  # 可选配置：设置吞吐量模式和生命周期策略
  throughput_mode = "bursting" # 默认是 'bursting'，可以根据需求调整
  
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS" # 使用预定义的值
  }

  tags = {
    Name = var.efs_name # 使用标签来定义名称
  }
}

# 如果需要限制访问EFS的安全组，可使用以下资源定义安全组
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow inbound traffic to EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 这里开放给所有IP，可根据实际情况修改
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}