terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet from networking stack"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name    = "Orbit Labs VPC"
    project = "Orbit-labs"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    name    = "Orbit Labs Subnet"
    project = "Orbit-labs"
  }
}

output "subnet_id" {
  value       = aws_subnet.main.id
  description = "ID of the main subnet"
}


data "aws_subnet" "selected" {
  id = var.subnet_id
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

resource "aws_security_group" "app" {
  name        = "orbit-labs-app-sg"
  description = "Security group for Orbit Labs app"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    name    = "Orbit Labs App SG"
    project = "Orbit-labs"
  }
}