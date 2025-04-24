# 定义变量
variable "vpc_id" {
  description = "The ID of the VPC where the EFS file system will be created."
  type        = string
}

variable "efs_name" {
  description = "The name for the EFS file system."
  type        = string
  default     = "openshift-efs" # 默认值，可以根据需要修改
}

variable "subnet_ids" {
  description = "List of subnet IDs for creating mount targets"
  type        = list(string)
}