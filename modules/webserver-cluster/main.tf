# Published to Terraform Cloud Private Registry

# This is the module that gets published to the private registry so any team member can reference it as:

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_name
    Owner       = var.team_name
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.cluster_name}-alb-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-alb-sg" })
  lifecycle { create_before_destroy = true }
}

resource "aws_security_group" "instance" {
  name_prefix = "${var.cluster_name}-instance-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-instance-sg" })
  lifecycle { create_before_destroy = true }
}

resource "aws_launch_template" "this" {
  name_prefix            = "${var.cluster_name}-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y && yum install -y httpd
    systemctl start httpd && systemctl enable httpd
    echo "<h1>Hello from ${var.cluster_name} - ${var.app_version}</h1>" > /var/www/html/index.html
    EOF
  )

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-lt" })
  lifecycle { create_before_destroy = true }
}

resource "aws_lb_target_group" "this" {
  name     = "${substr(var.cluster_name, 0, 20)}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path              = "/"
    matcher           = "200"
    interval          = 15
    healthy_threshold = 2
  }

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-tg" })
  lifecycle { create_before_destroy = true }
}

resource "aws_lb" "this" {
  name               = "${substr(var.cluster_name, 0, 28)}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
  tags               = merge(local.common_tags, { Name = "${var.cluster_name}-alb" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix               = "${var.cluster_name}-asg-"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.min_size
  vpc_zone_identifier       = data.aws_subnets.default.ids
  target_group_arns         = [aws_lb_target_group.this.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle { create_before_destroy = true }

  tag {
  key                 = "Name"
  value               = "${var.cluster_name}-instance"
  propagate_at_launch = true
}
tag {
  key                 = "Environment"
  value               = var.environment
  propagate_at_launch = true
}
tag {
  key                 = "ManagedBy"
  value               = "terraform"
  propagate_at_launch = true
}

}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = aws_lb_target_group.this.arn
}
