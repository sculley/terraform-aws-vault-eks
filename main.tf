# AWS KMS used for the Vault auto-unseal process
resource "aws_kms_key" "vault" {
  description             = "Hashicorp Vault KMS Auto-Unseal Key"
  deletion_window_in_days = 7

  tags = {
    Name = var.kms_key_name
  }
}

resource "aws_kms_alias" "vault" {
  name          = "alias/${var.kms_key_name}"
  target_key_id = aws_kms_key.vault.key_id
}

# AWS DynamoDB used for the Vault storage backend
resource "aws_dynamodb_table" "vault" {
  name           = var.dynamodb_table_name
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "Path"
  range_key      = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  tags = {
    Name = var.dynamodb_table_name
  }
}

# AWS IAM policy used for the Vault service account
resource "aws_iam_policy" "vault_service_account_policy" {
  name        = var.service_account_policy_name
  path        = "/"
  description = "Service account policy for Vault in EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.vault.arn
      },
      {
        Action = [
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
          "dynamodb:DescribeReservedCapacityOfferings",
          "dynamodb:DescribeReservedCapacity",
          "dynamodb:ListTables",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:CreateTable",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:GetRecords",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:DescribeTable"
        ],
        Effect   = "Allow"
        Resource = aws_dynamodb_table.vault.arn
      }
    ]
  })

  tags = {
    Name = var.service_account_policy_name
  }
}

# AWS IAM role used for the Vault service account
module "vault_service_account_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = var.service_account_role_name
  role_policy_arns = {
    vault_service_account_policy = resource.aws_iam_policy.vault_service_account_policy.arn
  }

  oidc_providers = {
    default = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:vault"]
    }
  }

  tags = {
    Name = var.service_account_role_name
  }
}

# Helm chart used to deploy Vault
resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  version          = "0.23.0"
  create_namespace = true
  namespace        = var.namespace

  # Any values passed into the module will be merged with the values from the template file
  values = [
      var.values,
      templatefile("${path.module}/templates/helm/values.yaml.tpl", {
        address                 = var.address
        cluser_address          = var.cluster_address
        dynamodb_read_capacity  = var.dynamodb_read_capacity
        dynamodb_table          = aws_dynamodb_table.vault.name
        dynamodb_write_capacity = var.dynamodb_write_capacity
        kms_key_id              = aws_kms_key.vault.key_id
        log_level               = var.log_level
        region                  = var.region
        tls_disable             = var.tls_disable
        vault_iam_role_arn      = module.vault_service_account_role.iam_role_arn
      }
    )
  ]
}
# We have to manually run `vault operator init` on master node in the cluster if this is the first time deploying Vault
# this will initialise the Vault cluster nodes and generate the unseal recovery keys and use KMS to auto-unseal the 
# cluster. Store  the recovery keys/root token in LastPass. Any subsequent deployments will use KMS to auto-unseal.
# This means we can't start adding stuff automatically to Vault until we've run `vault operator init` in the cluster
# so we will have to split out the vault configuration using terraform into a seperate repo and run it afterwards.