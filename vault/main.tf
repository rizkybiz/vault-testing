terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.2.1"
    }
  }
}

provider "vault" {
  alias     = "ns1"
  namespace = "ns1"
}

provider "vault" {
  alias     = "ns2"
  namespace = "ns2"
}

resource "vault_mount" "ns1_kv2" {
  provider = vault.ns1
  path     = "secret"
  type     = "kv-v2"
}

resource "vault_mount" "ns2_kv2" {
  provider = vault.ns2
  path     = "secret"
  type     = "kv-v2"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
  tune {
    listing_visibility = "unauth"
  }
}

resource "vault_generic_endpoint" "ns1-user" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/ns1-user"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["ns1-policy"],
  "password": "password"
}
EOT
}

resource "vault_generic_endpoint" "ns2-user" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/ns2-user"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["ns2-policy"],
  "password": "password"
}
EOT
}

resource "vault_policy" "ns1_policy" {
  name = "ns1-policy"

  policy = <<EOT
path "ns1/secret/*" {
  capabilities = ["create", "read", "update", "delete"]
}
EOT
}

resource "vault_policy" "ns2_policy" {
  name = "ns2-policy"

  policy = <<EOT
path "ns2/secret/*" {
  capabilities = ["create", "read", "update", "delete"]
}
EOT
}

resource "vault_identity_group" "ns1_group" {
  provider = vault.ns1
  name     = "ns1-group"
  type     = "internal"
  policies = ["ns1-policy"]
}

resource "vault_identity_entity" "ns1_user_entity" {
  name     = "ns1-user-entity"
  disabled = false
}

resource "vault_identity_group_member_entity_ids" "ns1_members" {
  provider          = vault.ns1
  exclusive         = true
  member_entity_ids = [vault_identity_entity.ns1_user_entity.id]
  group_id          = vault_identity_group.ns1_group.id
}

resource "vault_identity_entity_alias" "ns1_user_alias" {
  name           = "ns1-user-alias"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.ns1_user_entity.id
}

resource "vault_identity_entity" "ns2_user_entity" {
  name     = "ns2-user-entity"
  disabled = false
}

resource "vault_identity_entity_alias" "ns2_user_alias" {
  name           = "ns2-user-alias"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.ns2_user_entity.id
}

resource "vault_identity_entity" "ns2_user2_entity" {
  name     = "ns2-user2-entity"
  disabled = false
}