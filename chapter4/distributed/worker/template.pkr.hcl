packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "jenkins-worker"
}

variable "ami_description" {
  type    = string
  default = "Amazon Linux Image with Jenkins Worker"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "jenkins" {
  ami_name        = "${var.ami_prefix}-${local.timestamp}"
  ami_description = "${var.ami_description}"
  instance_type   = "${var.instance_type}"
  region          = "${var.region}"
  source_ami      = "ami-0b86aaed8ef90e45f"
  ssh_username = "ec2-user"
  run_tags = {
    Name = "jenkins-worker" 
  }
}

build {
  name    = "jenkins-ami-build"
  sources = ["source.amazon-ebs.jenkins"]
  provisioner "shell" {
    script          = "./setup.sh"
    execute_command = "sudo -E -S sh '{{ .Path }}'"
  }
}  