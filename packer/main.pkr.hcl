packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "kthw-source" {
  access_key    = "${{ var.AWS_ACCESS_KEY_ID }}"
  secret_key    = "${{ var.AWS_SECRET_ACCESS_KEY }}"
  region        = "${{ AWS_DEFAULT_REGION }}"
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
