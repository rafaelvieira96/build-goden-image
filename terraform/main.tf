terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# -------- Variáveis --------
variable "region"                 { type = string, default = "sa-east-1" }
variable "launch_template_name"   { type = string, default = "lc-azure-devops-agents" }
variable "autoscaling_group_name" { type = string } 
variable "new_ami_id"             { type = string } 

# -------- Data sources (leitura dos existentes) --------
data "aws_launch_template" "lt" {
  name = var.launch_template_name
}

data "aws_autoscaling_group" "asg" {
  name = var.autoscaling_group_name
}

# -------- Cria nova versão do LT, só trocando a AMI --------
resource "aws_launch_template_version" "new" {
  launch_template_id = data.aws_launch_template.lt.id
  source_version     = "$Latest"

  image_id = var.new_ami_id

  # (Opcional) você pode ajustar outros campos aqui se quiser, ex:
  # instance_type = "t3.medium"
  # user_data     = base64encode(file("userdata.sh"))
}

# -------- Gerencia o ASG existente e dispara Instance Refresh --------
# IMPORTANTE: para gerenciar um ASG existente, você deve importá-lo.
# Este recurso replica a config corrente do ASG (lida do data source)
# e só substitui o versionamento do Launch Template.
resource "aws_autoscaling_group" "this" {
  name                      = data.aws_autoscaling_group.asg.name
  min_size                  = data.aws_autoscaling_group.asg.min_size
  max_size                  = data.aws_autoscaling_group.asg.max_size
  desired_capacity          = data.aws_autoscaling_group.asg.desired_capacity
  health_check_type         = data.aws_autoscaling_group.asg.health_check_type
  health_check_grace_period = data.aws_autoscaling_group.asg.health_check_grace_period
  vpc_zone_identifier       = data.aws_autoscaling_group.asg.vpc_zone_identifier

  # Mantém mesmas tags (propaga = true preserva comportamento)
  dynamic "tag" {
    for_each = data.aws_autoscaling_group.asg.tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = true
    }
  }

  # Aponta para o MESMO LT porém numa NOVA versão
  launch_template {
    id      = data.aws_launch_template.lt.id
    version = aws_launch_template_version.new.version
  }

  # Instance Refresh para aplicar a nova AMI de forma controlada
  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup        = 60
      min_healthy_percentage = 90
      # opcional: checkpoint_percentages, etc.
    }
    triggers = ["launch_template"]
  }

  # Evita que o Terraform altere campos que você não quer gerenciar agora
  lifecycle {
    ignore_changes = [
      availability_zones,
      target_group_arns,
      capacity_rebalance,
      # acrescente aqui campos que não quer que TF mexa
    ]
  }
}
