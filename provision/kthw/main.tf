provider "aws" {}

terraform {
  backend "s3" {
    bucket         = "kthw-tf-backends"
    key            = "cust02.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kthw-tf-locktable"
    encrypt        = true
  }
}

variable public_key {
  description = "shell environment public key"
  type        = string
}

variable cust_id {
  description = "workflow input customer id"
  type        = string
}

variable sg_name {
  description = "generated security group name"
  type        = string
}

variable keypair_name {
  description = "generated key pair name"
  type        = string
}

locals {
    kthw_ami_id = data.aws_ami.kthw-base.id
    kthw_instance_type = "t4g.small"
    kthw_tags = {
        project = "kthw-project"
        roles = {
            jumpbox = "jumpbox"
            server = "server"
            node = "node"
        }
    }
}

data "aws_ami" "kthw-base" {
  most_recent = true
  filter {
    name   = "name"
    values = ["*kthw-base-ami"]
  }
  filter {
    name   = "tag:version"  # Update with the tag key
    values = ["latest"]      # Update with the tag value
  }
  owners = ["self"] # Filter by your AWS account as the owner
}

resource "aws_security_group" "sg_01" {
    name = var.sg_name
    tags = {
        Project = local.kthw_tags.project
        CustomerId = var.cust_id
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        self = true
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "local_keypair" {
    key_name = var.keypair_name
    public_key = var.public_key
    tags = {
      Project = local.kthw_tags.project
      CustomerId = var.cust_id
    }
}

resource "aws_instance" "kthw_jumpbox" {
  ami           = local.kthw_ami_id
  instance_type = local.kthw_instance_type
  key_name      = var.keypair_name
  security_groups = [
    aws_security_group.sg_01.name,
  ]
  tags = {
    Name = "jumpbox"
    KTHW_Resource = local.kthw_tags.roles.jumpbox
    Project = local.kthw_tags.project
    CustomerId = var.cust_id
  }
}
resource "aws_instance" "kthw_server" {
  ami           = local.kthw_ami_id
  instance_type = local.kthw_instance_type
  key_name      = var.keypair_name
  security_groups = [
    aws_security_group.sg_01.name,
  ]
  tags = {
    Name = "server"
    KTHW_Resource = local.kthw_tags.roles.server
    Project = local.kthw_tags.project
    CustomerId = var.cust_id
  }
}
resource "aws_instance" "kthw_node01" {
  ami           = local.kthw_ami_id
  instance_type = local.kthw_instance_type
  key_name      = var.keypair_name
  security_groups = [
    aws_security_group.sg_01.name,
  ]
  tags = {
    Name = "node-1"
    KTHW_Resource = local.kthw_tags.roles.node
    Project = local.kthw_tags.project
    CustomerId = var.cust_id
  }
}
resource "aws_instance" "kthw_node02" {
  ami           = local.kthw_ami_id
  instance_type = local.kthw_instance_type
  key_name      = var.keypair_name
  security_groups = [
    aws_security_group.sg_01.name,
  ]
  tags = {
    Name = "node-2"
    KTHW_Resource = local.kthw_tags.roles.node
    Project = local.kthw_tags.project
    CustomerId = var.cust_id
  }
}
output "ansible-output" {
    value = <<-EOT
all:
  children:
    sandbox:
      hosts:
        ${aws_instance.kthw_jumpbox.public_ip}:
        ${aws_instance.kthw_server.public_ip}:
        ${aws_instance.kthw_node01.public_ip}:
        ${aws_instance.kthw_node02.public_ip}:
    ${aws_instance.kthw_jumpbox.tags.KTHW_Resource}:
      hosts:
        ${aws_instance.kthw_jumpbox.public_ip}:
    ${aws_instance.kthw_server.tags.KTHW_Resource}:
      hosts:
        ${aws_instance.kthw_server.public_ip}:
    ${aws_instance.kthw_node01.tags.KTHW_Resource}:
      hosts:
        ${aws_instance.kthw_node01.public_ip}:
        ${aws_instance.kthw_node02.public_ip}:
    EOT
}
