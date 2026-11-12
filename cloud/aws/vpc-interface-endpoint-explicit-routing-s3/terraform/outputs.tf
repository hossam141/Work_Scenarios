output "vpc_id" {
  value = aws_vpc.main.id
}

output "s3_endpoint_dns_names" {
  description = "The specific DNS names generated for the S3 Interface Endpoint to be used in explicit application configurations."
  value       = aws_vpc_endpoint.s3_interface.dns_entry[*].dns_name
}