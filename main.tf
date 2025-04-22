# 创建 EFS 文件系统
resource "aws_efs_file_system" "example" {
  creation_token = "my-efs-token"
  name           = var.efs_name
  
  # 可选配置：设置吞吐量模式和生命周期策略
  throughput_mode = "bursting" # 默认是 'bursting'，可以根据需求调整
  
  # 示例生命周期策略，可根据需要添加或移除
  lifecycle_policy {
    transition_to_ia = "30 days"
  }

  tags = {
    Name = var.efs_name
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

output "efs_file_system_id" {
  value = aws_efs_file_system.example.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.example.dns_name
}