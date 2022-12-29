injector:
  logLevel: ${log_level}

server:
  loglevel: ${log_level}
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${vault_iam_role_arn}
      
  ha:
    enabled: true
    config: |
      ui = true

      listener "tcp" {
        tls_disable = ${tls_disable}
        address = "[::]:${address}"
        cluster_address = "[::]:${cluser_address}"
      }

      storage "dynamodb" {
        ha_enabled = "true"
        region = "${region}"
        table = "${dynamodb_table}"
        read_capacity = ${dynamodb_read_capacity}
        write_capacity = ${dynamodb_write_capacity}
      }

      seal "awskms" {
        region = "${region}"
        kms_key_id = "${kms_key_id}"
      }

      service_registration "kubernetes" {}