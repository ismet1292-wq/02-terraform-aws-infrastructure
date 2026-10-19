mock_provider "aws" {}

run "network_defaults" {
  command = plan
  assert {
    condition     = length(aws_instance.host) == 0 && length(aws_iam_role.host) == 0
    error_message = "Compute and host IAM resources must require explicit opt-in."
  }
  assert {
    condition     = length(aws_security_group.host.ingress) == 0
    error_message = "Do not allow inbound access."
  }
  assert {
    condition     = !aws_subnet.demo.map_public_ip_on_launch && aws_vpc.demo.enable_dns_support
    error_message = "Disable subnet auto-addressing and retain DNS for SSM connectivity."
  }
  assert {
    condition     = aws_vpc_security_group_egress_rule.https.from_port == 443 && aws_vpc_security_group_egress_rule.https.to_port == 443 && aws_vpc_security_group_egress_rule.https.ip_protocol == "tcp"
    error_message = "The explicit outbound rule must permit HTTPS only."
  }
}

run "host_safeguards" {
  command = plan
  variables {
    enable_host = true
    ami_id      = "ami-00000000000000000"
  }
  assert {
    condition     = aws_instance.host[0].metadata_options[0].http_tokens == "required" && aws_instance.host[0].metadata_options[0].http_put_response_hop_limit == 1
    error_message = "Require IMDSv2 with hop limit one."
  }
  assert {
    condition     = aws_instance.host[0].root_block_device[0].encrypted && aws_instance.host[0].root_block_device[0].delete_on_termination
    error_message = "Encrypt the root disk and delete it with the demo host."
  }
  assert {
    condition     = aws_instance.host[0].credit_specification[0].cpu_credits == "standard" && aws_instance.host[0].instance_type == "t3.micro"
    error_message = "Use the reviewed instance size without surplus CPU credits."
  }
}

run "reject_host_without_ami" {
  command = plan
  variables {
    enable_host = true
  }
  expect_failures = [var.ami_id]
}

run "reject_wrong_region" {
  command = plan
  variables {
    aws_region = "us-west-2"
  }
  expect_failures = [var.aws_region]
}
