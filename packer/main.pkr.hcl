packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_access_key" {
  type    = string
  default = env("AWS_ACCESS_KEY_ID")
}
variable "aws_secret_key" {
  type    = string
  default = env("AWS_SECRET_KEY_ID")
}
variable "aws_default_region" {
  type    = string
  default = env("AWS_DEFAULT_REGION")
}

source "amazon-ebs" "kthw-source" {
  access_key    = "${ var.aws_access_key }"
  secret_key    = "${ var.aws_secret_key }"
  region        = "${ var.aws_default_region }"
  ami_name      = "kthw-base-ami"
  source_ami    = "ami-0f58aa386a2280f35"
  instance_type = "t4g.small"
  ssh_username  = "admin"
}

build {
  sources = ["source.amazon-ebs.kthw-source"]

  provisioner "shell" {
    inline = [
      "echo hi > ~/hi.md"
    ]
  }
}
