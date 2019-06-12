region             = "us-gov-west-1"
availability_zones = ["us-gov-west-1a", "us-gov-west-1b", "us-gov-west-1c"]
rds_instance_count = 1
dns_suffix         = "jaygles.io"
vpc_cidr           = "10.1.0.0/16"
use_route53        = false
use_ssh_routes     = true
use_tcp_routes     = true