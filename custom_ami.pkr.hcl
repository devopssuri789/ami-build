# Define the required variables
variable "aws_region" {}
variable "source_ami" {}
variable "instance_type" {}

# Load variables from variables file
#source "vars" "vars" {
#  source = "variables.pkr.hcl"
#}
# Define the Packer build configuration
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Define the builders section
source "amazon-ebs" "custom_ami" {
  region              = var.aws_region
  source_ami          = var.source_ami
  instance_type       = var.instance_type
  ssh_username        = "ubuntu"
  #subnet_id           = "subnet-12345678"  # Update with your subnet ID
  #security_group_id   = "sg-12345678"      # Update with your security group ID

  tags = {
    Name = "Customized AMI"
  }
}

# Define the provisioners section
build {
  sources = ["source.amazon-ebs.custom_ami"]

  provisioner "shell" {
    inline = [
      "echo 'Customizing the AMI...'",
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }

  post-processors {
    ami {
      name                = "custom-ami"
      region              = var.aws_region
      snapshot_permissions {
        create_volume = "true"
        create_image  = "true"
        image_users    = "all"
      }
    }
  }
}
