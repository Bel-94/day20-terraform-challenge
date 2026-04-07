variables {
  cluster_name  = "test-cluster-day20"
  instance_type = "t2.micro"
  min_size      = 1
  max_size      = 2
  environment   = "dev"
  app_version   = "v3"
}

run "validate_asg_name_prefix" {
  command = plan

  assert {
    condition     = aws_autoscaling_group.this.name_prefix == "test-cluster-day20-asg-"
    error_message = "ASG name_prefix must be {cluster_name}-asg-"
  }
}

run "validate_instance_type" {
  command = plan

  assert {
    condition     = aws_launch_template.this.instance_type == "t2.micro"
    error_message = "Launch template instance_type must match var.instance_type"
  }
}

run "validate_health_check_type" {
  command = plan

  assert {
    condition     = aws_autoscaling_group.this.health_check_type == "ELB"
    error_message = "ASG must use ELB health checks, not EC2"
  }
}

run "validate_alb_sg_port" {
  command = plan

  assert {
    condition     = one(aws_security_group.alb.ingress).from_port == 80
    error_message = "ALB security group must allow port 80 inbound"
  }
}

run "validate_min_size" {
  command = plan

  assert {
    condition     = aws_autoscaling_group.this.min_size == 1
    error_message = "ASG min_size must match var.min_size"
  }
}

run "validate_max_size" {
  command = plan

  assert {
    condition     = aws_autoscaling_group.this.max_size == 2
    error_message = "ASG max_size must match var.max_size"
  }
}

run "validate_environment_tag" {
  command = plan

  assert {
    condition = anytrue([
      for tag in aws_autoscaling_group.this.tag :
      tag.key == "Environment" && tag.value == "dev" && tag.propagate_at_launch == true
    ])
    error_message = "Environment tag must propagate to instances"
  }
}

run "reject_invalid_environment" {
  command = plan

  variables {
    environment = "sandbox"
  }

  expect_failures = [var.environment]
}

run "reject_invalid_instance_type" {
  command = plan

  variables {
    instance_type = "m5.large"
  }

  expect_failures = [var.instance_type]
}
