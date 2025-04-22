# 创建 IAM 策略
resource "aws_iam_policy" "efs_csi_policy" {
  name        = "${var.cluster_name}-aws-efs-csi"
  description = "IAM policy for AWS EFS CSI Driver Operator"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "ec2:DescribeAvailabilityZones",
          "elasticfilesystem:TagResource"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["elasticfilesystem:CreateAccessPoint"],
        Resource = "*",
        Condition = {
          StringLike = {
            "aws:RequestTag/efs.csi.aws.com/cluster" = "true"
          }
        }
      },
      {
        Effect   = "Allow",
        Action   = ["elasticfilesystem:DeleteAccessPoint"],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:ResourceTag/efs.csi.aws.com/cluster" = "true"
          }
        }
      }
    ]
  })
}

output "policy_arn" {
  value = aws_iam_policy.efs_csi_policy.arn
}

# 创建 IAM 角色
resource "aws_iam_role" "efs_csi_operator_role" {
  name = "${var.cluster_name}-aws-efs-csi-operator"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${var.oidc_provider_url}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = [
              "system:serviceaccount:openshift-cluster-csi-drivers:aws-efs-csi-driver-operator",
              "system:serviceaccount:openshift-cluster-csi-drivers:aws-efs-csi-driver-controller-sa"
            ]
          }
        }
      }
    ]
  })
}

output "role_arn" {
  value = aws_iam_role.efs_csi_operator_role.arn
}

# 将策略附加到角色
resource "aws_iam_role_policy_attachment" "attach_efs_csi_policy" {
  role       = aws_iam_role.efs_csi_operator_role.name
  policy_arn = aws_iam_policy.efs_csi_policy.arn
}