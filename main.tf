terraform {
  required_version = ">= 1.2.0"
}

provider "consul" {
  address    = "localhost:8500"
  datacenter = "dc1"
}

variable "environment" {
    type = string
}

data "consul_keys" "MY-VM" {
  key {
    name    = "VM"
    path    = "TERRAFORM/${var.environment}/MY-VM"
  }
}

locals {
  json_data = jsondecode(data.consul_keys.MY-VM.var.VM)
}

module "my-vm"{
    source = "git::https://github.com/ahmadbacchus/IAC-Terraform-VM-Module.git?ref=v1.0.0"
    instance_type          = local.json_data.INSTANCE_TYPE
    vpc_security_group_ids = local.json_data.SECURITY_GROUP
    subnet_id = local.json_data.SUBNET
    ami                    = local.json_data.AMI
    tags-name              = local.json_data.NAME
    tags-descr             = local.json_data.DESCR
    tags-env               = "${var.environment}"
    tags-owner             = local.json_data.OWNER
}