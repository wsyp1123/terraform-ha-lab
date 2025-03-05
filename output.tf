output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_alb.nginx_lb.dns_name
}
