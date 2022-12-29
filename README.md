# terraform-aws-vault-eks

<p align="center">
  <img src="https://raw.githubusercontent.com/sculley/terraform-aws-vault-eks/main/vault-diagram.png">
</p>

Terraform module to deploy Vault using Helm to an AWS EKS cluster.

Vault is configured to run in High Availability mode using DynamoDB as the storage backend and KMS to provide auto-unsealing.

After this module has been deployed, if this is the first time its been deployed to a Kubernetes cluster we need to manually initialise the Vault you can do this by running the commands below

```shell
$ kubectl port-forward vault-0 8200:8200 -n vault &
$ export VAULT_ADDR=http://localhost:8200

$ vault status
Key                      Value
---                      -----
Recovery Seal Type       awskms
Initialized              false
Sealed                   true
Total Recovery Shares    0
Threshold                0
Unseal Progress          0/0
Unseal Nonce             n/a
Version                  1.12.1
Build Date               2022-10-27T12:32:05Z
Storage Type             dynamodb
HA Enabled               true

$ vault operator init
vault operator init
Recovery Key 1: REDACTED
Recovery Key 2: REDACTED
Recovery Key 3: REDACTED
Recovery Key 4: REDACTED
Recovery Key 5: REDACTED

Initial Root Token: REDACTED

Success! Vault is initialized

Recovery key initialized with 5 key shares and a key threshold of 3. Please
securely distribute the key shares printed above.
```

Make sure to save the output of the `vault operator init` command as this will contain your recovery keys and root token.

By default the Vault UI is not exposed outside the cluster, if you want to create a LoadBalancer to expose the Vault/UI you will need to set the `server.service.type` value to `LoadBalancer` and provide any additional annotations you may need. You can do this by adding the values to your `Values.yaml` file and passing it to the module using templatefile.

## Usage

```hcl
module "vault" {
  source = "github.com/sculley/terraform-aws-vault-eks"

  dynamodb_table_name         = "vault-dynamodb-table"
  kms_key_name                = "vault-kms-unseal-key"
  namespace                   = "vault"
  oidc_provider_arn           = "https://oidc.eks.eu-west-2.amazonaws.com/id/FE901B2115344567E572DEEK8X329C1A"
  region                      = "eu-west-2"
  service_account_policy_name = "vault-service-account-policy"
  service_account_role_name   = "vault-service-account-role"
  values                      = templatefile("${path.module}/values.yaml", {})
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vault_service_account_role"></a> [vault\_service\_account\_role](#module\_vault\_service\_account\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.vault_service_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [helm_release.vault](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address"></a> [address](#input\_address) | (Optional) The address of the Vault server. Defaults to `[::]:8200`. | `string` | `"[::]:8200"` | no |
| <a name="input_cluster_address"></a> [cluster\_address](#input\_cluster\_address) | (Optional) The address of the Vault cluster. Defaults to `[::]:8201`. | `string` | `"[::]:8201"` | no |
| <a name="input_dynamodb_read_capacity"></a> [dynamodb\_read\_capacity](#input\_dynamodb\_read\_capacity) | (Optional) The read capacity for the DynamoDB table. Defaults to `5`. | `string` | `"5"` | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | (Optional) The name of the DynamoDB table. Defaults to `vault`. | `string` | `"vault"` | no |
| <a name="input_dynamodb_write_capacity"></a> [dynamodb\_write\_capacity](#input\_dynamodb\_write\_capacity) | (Optional) The write capacity for the DynamoDB table. Defaults to `5`. | `string` | `"5"` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | (Optional) The name of the KMS key. Defaults to `vault-kms`. | `string` | `"vault-kms"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | (Optional) The log level for Vault. Defaults to `info`. | `string` | `"info"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | (Optional) The namespace to deploy the Vault Helm chart into. Defaults to `vault`. | `string` | `"vault"` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | The ARN of the OIDC provider. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to create the KMS & DynamoDB used with Vault | `string` | n/a | yes |
| <a name="input_service_account_policy_name"></a> [service\_account\_policy\_name](#input\_service\_account\_policy\_name) | (Optional) The name of the IAM policy for the Vault service account. Defaults to `vault-service-account-policy`. | `string` | `"vault-service-account-policy"` | no |
| <a name="input_service_account_role_name"></a> [service\_account\_role\_name](#input\_service\_account\_role\_name) | (Optional) The name of the IAM role for the Vault service account. Defaults to `vault-service-account-role`. | `string` | `"vault-service-account-role"` | no |
| <a name="input_tls_disable"></a> [tls\_disable](#input\_tls\_disable) | (Optional) Disable TLS. Defaults to `1`. | `number` | `1` | no |
| <a name="input_values"></a> [values](#input\_values) | (Optional) Additional values to pass to the Vault Helm chart. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_dynamodb_arn"></a> [aws\_dynamodb\_arn](#output\_aws\_dynamodb\_arn) | n/a |
| <a name="output_aws_kms_key_arn"></a> [aws\_kms\_key\_arn](#output\_aws\_kms\_key\_arn) | n/a |
| <a name="output_aws_kms_key_id"></a> [aws\_kms\_key\_id](#output\_aws\_kms\_key\_id) | n/a |
