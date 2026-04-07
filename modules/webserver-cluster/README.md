# terraform-aws-webserver-cluster

A production-grade Auto Scaling web server cluster behind an Application Load Balancer.

## Usage

### From Terraform Cloud Private Registry

```hcl
module "webserver_cluster" {
  source  = "app.terraform.io/belinda-terraform-challenge/webserver-cluster/aws"
  version = "1.0.0"

  cluster_name  = "prod-cluster"
  instance_type = "t2.medium"
  min_size      = 3
  max_size      = 10
  environment   = "production"
}
```

### From GitHub (development)

```hcl
module "webserver_cluster" {
  source = "github.com/Bel-94/terraform-aws-webserver-cluster?ref=v1.0.0"

  cluster_name = "dev-cluster"
  environment  = "dev"
}
```

## Resources Created

- Application Load Balancer (ALB)
- ALB Security Group (HTTP 80 from 0.0.0.0/0)
- Instance Security Group (HTTP 80 from ALB only)
- Launch Template
- Auto Scaling Group (ELB health checks)
- ALB Target Group with health checks
- ALB Listener

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| cluster_name | Base name for all resources | string | — | yes |
| instance_type | EC2 instance type (t2 or t3 only) | string | t2.micro | no |
| min_size | Minimum ASG instance count | number | 2 | no |
| max_size | Maximum ASG instance count | number | 4 | no |
| environment | dev, staging, or production | string | dev | no |
| app_version | Version label for HTML and tags | string | v1 | no |

## Outputs

| Name | Description |
|---|---|
| alb_dns_name | ALB DNS name |
| alb_url | Full http:// URL |
| asg_name | Auto Scaling Group name |
| alb_sg_id | ALB security group ID |
| instance_sg_id | Instance security group ID |

## Version History

| Version | Changes |
|---|---|
| 1.0.0 | Initial release |
