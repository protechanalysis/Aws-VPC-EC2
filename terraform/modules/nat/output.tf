output "nat_gateway_id" {
  value = aws_nat_gateway.test_nat_gateway.id
}

output "eip" {
  value = aws_eip.test_eip.id
}
