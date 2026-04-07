output "alb_dns_name" {
  description = "ALB DNS name — use this to verify the v3 response after deploy"
  value       = aws_lb.this.dns_name
}

output "alb_url" {
  description = "Full URL to verify the deployed version"
  value       = "http://${aws_lb.this.dns_name}"
}

output "asg_name" {
  description = "ASG name — use to check instance health after deploy"
  value       = aws_autoscaling_group.this.name
}

output "app_version" {
  description = "The application version currently deployed"
  value       = var.app_version
}

output "verification_commands" {
  description = "Run these after apply to confirm the v3 deployment succeeded"
  value = {
    check_response    = "curl -s http://${aws_lb.this.dns_name} | grep -o 'v[0-9]*'"
    check_health      = "aws elbv2 describe-target-health --target-group-arn ${aws_lb_target_group.this.arn} --query 'TargetHealthDescriptions[*].{ID:Target.Id,State:TargetHealth.State}' --output table"
    monitor_traffic   = "while true; do curl -s http://${aws_lb.this.dns_name} | grep -o 'v[0-9]*'; echo ''; sleep 2; done"
  }
}
