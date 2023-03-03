output "public_ip" {
  value = [aws_instance.server1.*.public_ip, aws_instance.server2.*.public_ip]
}


output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.post-bd.port
  sensitive   = true
}