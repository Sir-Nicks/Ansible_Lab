output "ansible" {
  value = aws_instance.ansible.public_ip
}

output "redhat" {
  value = aws_instance.redhat.public_ip
}

output "ubuntu" {
  value = aws_instance.ubuntu.public_ip
}
