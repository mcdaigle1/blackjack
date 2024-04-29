terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region  = "us-west-1"
  profile = "terraform"
}

##################################################################################
# Create VPC and subnets
##################################################################################
resource "aws_vpc" "kube_demo_vpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "kube_demo_vpc"
  }
}

resource "aws_subnet" "kube_demo_us_west_1a_private_sn" {
  vpc_id            = aws_vpc.kube_demo_vpc.id
  availability_zone = "us-west-1a"
  cidr_block        = "10.1.1.0/24"

  tags = {
    Name = "kube_demo_us_west_1a_private_sn"
  }
}

resource "aws_subnet" "kube_demo_us_west_1a_public_sn" {
  vpc_id            = aws_vpc.kube_demo_vpc.id
  availability_zone = "us-west-1a"
  cidr_block        = "10.1.2.0/24"

  tags = {
    Name = "kube_demo_us_west_1a_public_sn"
  }
}

resource "aws_subnet" "kube_demo_us_west_1c_private_sn" {
  vpc_id            = aws_vpc.kube_demo_vpc.id
  availability_zone = "us-west-1c"
  cidr_block        = "10.1.3.0/24"

  tags = {
    Name = "kube_demo_us_west_1c_private_sn"
  }
}

resource "aws_subnet" "kube_demo_us_west_1c_public_sn" {
  vpc_id            = aws_vpc.kube_demo_vpc.id
  availability_zone = "us-west-1c"
  cidr_block        = "10.1.4.0/24"

  tags = {
    Name = "kube_demo_us_west_1c_public_sn"
  }
}

##################################################################################
# Create gateways and NATs
##################################################################################
resource "aws_internet_gateway" "kube_demo_igw" {
  vpc_id = aws_vpc.kube_demo_vpc.id

  tags = {
    Name = "kube_demo_igw"
  }
}

resource "aws_eip" "kube_demo_us_west_1a_nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "kube_demo_us_west_1a_nat_gw" {
  allocation_id = aws_eip.kube_demo_us_west_1a_nat_gw_eip.allocation_id
  subnet_id     = aws_subnet.kube_demo_us_west_1a_public_sn.id

  tags = {
    Name = "kube_demo_us_west_1a_nat_gw"
  }

  depends_on = [aws_internet_gateway.kube_demo_igw]
}

resource "aws_eip" "kube_demo_us_west_1c_nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "kube_demo_us_west_1c_nat_gw" {
  allocation_id = aws_eip.kube_demo_us_west_1c_nat_gw_eip.allocation_id
  subnet_id     = aws_subnet.kube_demo_us_west_1c_public_sn.id

  tags = {
    Name = "kube_demo_us_west_1c_nat_gw"
  }

  depends_on = [aws_internet_gateway.kube_demo_igw]
}

##################################################################################
# Create app EC2 instance
##################################################################################
resource "aws_network_interface" "kube_demo_us_west_1a_ni" {
  subnet_id   = aws_subnet.kube_demo_us_west_1a_private_sn.id
  private_ips = []

  tags = {
    Name = "kube_demo_us_west_1a_ni"
  }
}

resource "aws_instance" "kube_demo_app_instance" {
  ami           = "ami-0b990d3cfca306617"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.kube_demo_us_west_1a_ni.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}

# ##################################################################################
# # Create ELB
# ##################################################################################
#
# # Create a new load balancer
# resource "aws_elb" "bar" {
#   name               = "blackjack-elb"
#   availability_zones = ["us-west-1a", "us-west-1c"]
#
# #   access_logs {
# #     bucket        = "foo"
# #     bucket_prefix = "bar"
# #     interval      = 60
# #   }
#
#   listener {
#     instance_port     = 8000
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }
#
# #   listener {
# #     instance_port      = 8000
# #     instance_protocol  = "http"
# #     lb_port            = 443
# #     lb_protocol        = "https"
# #     ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
# #   }
#
#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     target              = "HTTP:8000/"
#     interval            = 30
#   }
#
#   instances                   = [aws_instance.foo.id]
#   cross_zone_load_balancing   = true
#   idle_timeout                = 400
#   connection_draining         = true
#   connection_draining_timeout = 400
#
#   tags = {
#     Name = "foobar-terraform-elb"
#   }
# }


