output "aws_kms_key_arn" {
  value = resource.aws_kms_key.vault.arn
}

output "aws_kms_key_id" {
  value = resource.aws_kms_key.vault.id
}

output "aws_dynamodb_arn" {
  value = resource.aws_dynamodb_table.vault.arn
}