terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.2.1"
    }
  }
}

provider "vault" {}

resource "vault_namespace" "ns1" {
  path = "ns1"
}

resource "vault_namespace" "ns2" {
  path = "ns2"
}
