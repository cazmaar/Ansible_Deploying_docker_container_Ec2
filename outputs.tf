output "ec2-public-ip" {
  value = module.ec2_instance.ec2-details.public_ip
}