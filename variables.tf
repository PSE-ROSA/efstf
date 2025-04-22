variable "cluster_name" {
  description = "The name of the ROSA cluster."
  type        = string
}

variable "aws_account_id" {
  description = "Your AWS Account ID."
  type        = string
}

variable "oidc_provider_url" {
  description = "The OpenShift OIDC provider URL."
  type        = string
}