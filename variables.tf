variable "vpc_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "key_pair" {}
# variable "public_key_location" {}
variable "private_key_location" {}
variable "subnet_cidr_block" {
    #default = ""  # you can define default values for variables that do not change value. So you don't change does ones in the CI/Cd pipeline
}