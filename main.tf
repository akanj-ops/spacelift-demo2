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

# 1. Input variable for external subnet data lookup
variable "subnet_id" {
  type        = string
  description = "ID of the subnet from networking stack"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "Orbit Labs VPC"
    project = "Orbit-labs"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name    = "Orbit Labs Subnet"
    project = "Orbit-labs"
  }
}

# FIX: Renamed from "subnet_id" to prevent collision with the variable
output "main_subnet_id" {
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
    Name    = "Orbit Labs App SG"
    project = "Orbit-labs"
  }
}