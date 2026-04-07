output "alb_dns_name" {
  description = "ALB DNS name for the cluster"
  value       = aws_lb.this.dns_name
}

output "alb_url" {
  description = "Full HTTP URL for the cluster"
  value       = "http://${aws_lb.this.dns_name}"
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.this.name
}

output "alb_sg_id" {
  description = "Security Group ID attached to the ALB"
  value       = aws_security_group.alb.id
}

output "instance_sg_id" {
  description = "Security Group ID attached to EC2 instances"
  value       = aws_security_group.instance.id
}
