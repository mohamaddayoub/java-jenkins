    provider "aws" {
        region = "us-east-2"
    }

    resource "aws_vpc" "myapp_vpc" {
        
        cidr_block = var.vpc_cidr_block
        
        tags = {
        Name = "${var.environment}-vpc"
    }
    }

    resource "aws_subnet" "myapp_subnet" {
        vpc_id     = aws_vpc.myapp_vpc.id
        cidr_block = var.subnet_cidr_block
        availability_zone = var.az

        tags = {
        Name = "${var.environment}-subnet"
        }
    }

    resource "aws_default_security_group" "default" {
    vpc_id = aws_vpc.myapp_vpc.id

    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "-1"
        cidr_blocks = [var.my_ip]

    }
    ingress {
        protocol  = "-1"
        from_port = 8080
        to_port   = 8080
        cidr_blocks = [var.my_ip]

    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

        tags = {
            Name = "${var.environment}-sg"
     }

    }

    resource "aws_internet_gateway" "myapp_gw" {
    vpc_id = aws_vpc.myapp_vpc.id

    tags = {
        Name = "${var.environment}-gw"
        }
    }

    resource "aws_default_route_table" "myapp_rt" {
    default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id

    route {
        cidr_block = var.subnet_cidr_block
        gateway_id = aws_internet_gateway.myapp_gw.id

        }

    tags = {
        Name = "${var.environment}-rt"
        }
    }

    data "aws_ami" "latest_amazon_linux" {
        most_recent = true
        owners = ["137112412989"]
        filter {
        name = "name"
        values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
        }
        filter {
        name = "virtualization-type"
        values = ["hvm"]
        }
    }


    resource "aws_instance" "myapp_server-1" {
        ami = data.aws_ami.latest_amazon_linux.id
        instance_type = var.instance_type
        subnet_id = aws_subnet.myapp_subnet.id
        availability_zone = "us-east-2a"
        key_name = "jenkins-server"
        associate_public_ip_address = true
        vpc_security_group_ids = [aws_default_security_group.default.id]
        user_data = file("entry_script.sh")

        tags = {
            Name = "${var.environment}-server-1"
            }
    }

    output "ec2_public_ip" {
        value = aws_instance.myapp_server-1.public_ip
    }