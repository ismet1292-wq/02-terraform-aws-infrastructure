output "selected_region" {
  value = var.aws_region
}
output "vpc_id" {
  value = aws_vpc.demo.id
}
output "subnet_id" {
  value = aws_subnet.demo.id
}
output "security_group_id" {
  value = aws_security_group.host.id
}
output "instance_id" {
  value = one(aws_instance.host[*].id)
}
