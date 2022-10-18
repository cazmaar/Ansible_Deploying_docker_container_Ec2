provider "aws" {
  region = "eu-west-2"
}


#creating the terraform remote storage
terraform {
	required_version = ">= 0.12"
	backend "s3" {
		bucket =  "kazeem-terraform-storage" #bucketname
		key = "myapp/state.tfstate" #path to storing state in s3 bucket.
		region= "eu-west-2" #where your bucket is
}
}




resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" : "${var.env_prefix}-vpc"
  }
}
module "my-app-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  env_prefix = var.env_prefix
  availability_zone = var.availability_zone
  vpc_id = aws_vpc.development-vpc.id
}  

module "ec2_instance" {
  source = "./modules/ec2_server"
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.development-vpc.id
  my_ip = var.my_ip
  instance_type = var.instance_type
  subnet_id = module.my-app-subnet.subnet.id
  availability_zone = var.availability_zone
  key_name = var.key_pair
  private_key_location = var.private_key_location
}
