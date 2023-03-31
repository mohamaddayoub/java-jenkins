variable "environment" {
    default = "dev"
}
variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
    default = "10.0.10.0/24"
}
variable "az" {
    default = "us-east-2a"
}

variable "my_ip" {
    default = "0.0.0.0/0"
}


variable "my_public_key_location" {
    default = "/Users/md/.ssh/id_rsa.pub"
}
variable "instance_type" {
    default = "t2.micro"
}
