# Network deployment results - October 19, 2026

The user authorized the reviewed network-only plan. Terraform applied
**8 additions, 0 changes, 0 deletions** in us-east-1. No EC2 host, host IAM role,
root disk, NAT gateway, load balancer, or public IPv4 allocation was created.
The optional host remains disabled. No changes were made to CloudOps resources.

## Verified through AWS APIs

- VPC: vpc-0d699153fc371b108, CIDR 10.43.0.0/16.
- Subnet: subnet-0e385165725f3b001, available in us-east-1a,
  CIDR 10.43.1.0/24, automatic public IPv4 addressing disabled.
- Route table: rtb-06835b1b38adb9f59, associated with that subnet.
- Active default route through internet gateway igw-081259f8974fe4115.
- Security group: sg-0bec1bbe4813ae369, zero inbound rules and only
  TCP 443 outbound to 0.0.0.0/0.
- No active project-tagged EC2 instances were found.

[Recorded AWS verification](network-verification.json) contains the observations.
Configuration tests use a mocked provider; these live read checks separately
verify the deployed network. They do not prove an EC2 host can boot or reach SSM.

A follow-up live Terraform plan returned no changes (exit code 0), confirming
the recorded configuration matched the deployed network.

## Ownership and remaining work

The network remains deployed. Preserve its local, Git-ignored Terraform state;
this root owns these resources independently of CloudOps Observatory.
Do not remove state to start over. Review a destroy plan before approved cleanup.

EC2 deployment, SSM connectivity, reboot behavior, and cleanup of a future host
remain unverified for this project. Before enabling the host, review current
AMI ownership/compatibility, operator permissions, IAM scope, costs, duration,
and cleanup. The old CloudOps demo allowance does not authorize a new paid host.
