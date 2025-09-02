packer {
  required_version = ">= 1.10.0"
  required_plugins {
    amazon = {
      source = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

variable "region" {
  type = string
  default = "sa-east-1"
}

variable "base_ami_id" {
  type = string
  default = "ami-02556f6726aa38019"
}

variable "instance_type" {
  type = string
  default = "t3.medium"
}

variable "ssh_username" {
  type = string
  default = "ec2-user"
}

source "amazon-ebs" "golden" {
  region = var.region
  instance_type = var.instance_type
  ssh_username = var.ssh_username
  ami_name = "golden-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  ami_description = "Golden AMI via Packer"
  source_ami = var.base_ami_id
  associate_public_ip_address = false
  # opcional: subnets/sgs se sua VPC exigir
  subnet_id = "subnet-037fe584d07f3f155"
  security_group_id = "sg-05c41e22780831a07"

  launch_block_device_mappings {
    device_name = "/dev/xvda"
    volume_size = 100
    volume_type = "gp3"
    delete_on_termination = true
    encrypted = true
  }

  tags = {
    Workload = "AzureDevops Agent"
    Purpose = "golden_image_build"
    BuiltBy = "packer"
  }
}

build {
  name = "golden-build"
  sources = ["source.amazon-ebs.golden"]

  provisioner "shell" {
    script = "./install.sh"
  }

  # gera manifest JSON com o AMI ID (fácil de consumir no passo 2)
  post-processor "manifest" {
    output = "manifest.json"
  }
}
