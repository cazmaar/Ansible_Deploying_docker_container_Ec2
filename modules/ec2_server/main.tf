resource "aws_security_group" "allow_tls" {
  name        = "${var.env_prefix}-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH INTO INSTANCE"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "APP PORT INTO INSTANCE"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "APP PORT INTO INSTANCE"
    from_port   = 4007
    to_port     = 4007
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "APP PORT INTO INSTANCE"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest_amazon_linux_image" {
  most_recent = true
  owners      = [137112412989]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "dev-ec2-instance" {
  ami                         = data.aws_ami.latest_amazon_linux_image.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = var.key_name
  tags = {
    "Name" = "${var.env_prefix}-server"
    # yh
  }
#self.public_ip for when you want to use a value in itself
}

#since we are not provisioning a server its better to use null resource.

resource "null_resource" "configure_server" {
  provisioner "local-exec" {  #provisioners are used to execute commands in terraform
  # triggers={ #a trigger  to trigger when this should be executed
  #   trigger=aws_instance.dev-ec2-instance.public_ip
  # }
    #local exec - is for running it locally on my machine.
    # working_dir = if it is in a different directory you have to switch to that directory.
    command = "ansible-playbook -u ec2-user --inventory ${aws_instance.dev-ec2-instance.public_ip}, --private-key ${var.private_key_location} deploy-docker.yaml" #automatically running ansible after terraform is done provisioning server using provisioner.
  }
}