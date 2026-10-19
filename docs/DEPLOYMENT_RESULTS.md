# Network deployment results - October 19, 2026

The user authorized the reviewed network-only plan. Terraform applied
**8 additions, 0 changes, 0 deletions** in us-east-1. No EC2 host, host IAM role,
root disk, NAT gateway, load balancer, or public IPv4 allocation was created.
At this network milestone the optional host remained disabled. It was later tested separately as recorded below. No changes were made to CloudOps resources.

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

The temporary EC2 deployment, SSM registration, and cleanup subsequently passed as recorded below. Reboot behavior and interactive sessions remain unverified for this project. Before enabling the host, review current
AMI ownership/compatibility, operator permissions, IAM scope, costs, duration,
and cleanup. The old CloudOps demo allowance does not authorize a new paid host.


## Temporary EC2 host demonstration

The user approved a one-hour maximum demonstration with a $1 allowance and a
project-scoped permissions draft. This was an operating limit, not an enforced
AWS spending cap. The host launched at 20:56:34 UTC on October 19, 2026.

Terraform added four host resources without changing the network. Live checks
confirmed Amazon Linux, a t3.micro with standard CPU credits, required IMDSv2
with hop limit one, and an encrypted 8 GiB gp3 root disk configured for deletion
on termination. Both EC2 instance and system status checks passed. SSM reported
Online and its connection status was connected.

This validated host boot and SSM registration. No application was installed,
interactive session opened, or reboot recovery tested in this project.
[Host verification](project02-host-verification.json) records the observations.

After the checks, a reviewed plan removed only the four host resources. By
21:00:50 UTC AWS confirmed instance i-0674380f539b38a79 terminated and root disk
vol-00792f38fa7f2e60b absent. Terraform state contained only the eight network
resources; a follow-up live plan found no changes. The temporary inline user
policy Project02TemporaryHostDeployment was also removed in the AWS console.
[Cleanup evidence](project02-host-cleanup.json) records resource removal.

The run lasted approximately four minutes. Actual billing and credit usage were
not verified. The host is disabled in the default configuration; another paid
deployment requires a new reviewed plan, permission scope, and cost approval.
