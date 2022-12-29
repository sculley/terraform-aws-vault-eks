variable "address" {
  description = "(Optional) The address of the Vault server. Defaults to `[::]:8200`."
  type        = string
  default     = "[::]:8200"
}

variable "cluster_address" {
  description = "(Optional) The address of the Vault cluster. Defaults to `[::]:8201`."
  type        = string
  default     = "[::]:8201"
}

variable "dynamodb_read_capacity" {
  description = "(Optional) The read capacity for the DynamoDB table. Defaults to `5`."
  type        = string
  default     = "5"
}

variable "dynamodb_table_name" {
  description = "(Optional) The name of the DynamoDB table. Defaults to `vault`."
  type        = string
  default     = "vault"
}

variable "dynamodb_write_capacity" {
  description = "(Optional) The write capacity for the DynamoDB table. Defaults to `5`."
  type        = string
  default     = "5"
}

variable "kms_key_name" {
  description = "(Optional) The name of the KMS key. Defaults to `vault-kms`."
  type        = string
  default     = "vault-kms"
}

variable "log_level" {
  description = "(Optional) The log level for Vault. Defaults to `info`."
  type        = string
  default     = "info"
}

variable "namespace" {
  description = "(Optional) The namespace to deploy the Vault Helm chart into. Defaults to `vault`."
  type        = string
  default     = "vault"
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider."
  type        = string
}

variable "region" {
  description = "The AWS region to create the KMS & DynamoDB used with Vault"
  type        = string
}

variable "service_account_policy_name" {
  description = "(Optional) The name of the IAM policy for the Vault service account. Defaults to `vault-service-account-policy`."
  type        = string
  default     = "vault-service-account-policy"
}

variable "service_account_role_name" {
  description = "(Optional) The name of the IAM role for the Vault service account. Defaults to `vault-service-account-role`."
  type        = string
  default     = "vault-service-account-role"
}

variable "tls_disable" {
  description = "(Optional) Disable TLS. Defaults to `1`."
  type = number
  default = 1
}

variable "values" {
  description = "(Optional) Additional values to pass to the Vault Helm chart."
  type        = string
  default     = ""
}