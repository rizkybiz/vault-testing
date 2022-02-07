terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

variable "vault_license" {
  type        = string
  description = "vault enterprise license"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "vault-network" {
  name   = "vault-network"
  driver = "bridge"
}

resource "docker_image" "vault" {
  name = "hashicorp/vault-enterprise:1.9.3-ent"
}

resource "docker_container" "vault" {
  image = docker_image.vault.latest
  name  = "dev-vault"
  networks_advanced {
    name = docker_network.vault-network.name
  }
  ipc_mode   = "private"
  privileged = true
  ports {
    internal = 8200
    external = 8200
  }
  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=root",
    "VAULT_LICENSE=${var.vault_license}"
  ]
}