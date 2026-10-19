# Terraform AWS Infrastructure

A standalone DevOps portfolio project for a small AWS network and an optional
Systems Manager-managed EC2 demonstration host in us-east-1.

**Status:** the eight-resource network was deployed and verified in us-east-1
on October 19, 2026. The optional EC2 host remains disabled and has not been
deployed. See [deployment evidence](docs/DEPLOYMENT_RESULTS.md). The separate
[CloudOps Observatory demo](https://github.com/ismet1292-wq/cloudops-observatory/blob/main/docs/AWS_DEMO_RESULTS.md)
was deployed, tested, and cleaned up; its resources and Terraform state are not
owned by this repository.

## Architecture

```text
VPC 10.43.0.0/16
  Public subnet 10.43.1.0/24
    Route table -> Internet gateway (outbound access)
    Security group: no inbound; outbound TCP 443
    Optional t3.micro -> encrypted 8 GiB root disk
                     -> instance role / SSM Core policy
Operator -> AWS Systems Manager -> host (no inbound SSH)
```

The default configuration defines eight network resources. Setting enable_host
adds an instance, role, managed policy attachment, and instance profile. The host
has an auto-assigned public IPv4 for outbound SSM connectivity; the subnet does
not assign addresses automatically. There is no NAT gateway, load balancer,
Elastic IP, application installation, or persistent data disk in this project.

## Validate locally in PowerShell

Use Terraform 1.9 or later (CI uses 1.15.8). Run from this repository:

```powershell
terraform fmt -check -recursive
terraform init -backend=false -input=false -lockfile=readonly
terraform validate -no-color
terraform test -no-color
```

These commands do not create AWS resources. The tests use a mocked provider and
synthetic AMI ID; they do not make AWS API calls or prove that a real host boots.
Provider initialization requires internet access to download the provider when
it is not already cached. Commit the dependency lock file.

Tests cover disabled-by-default compute, no inbound access, HTTPS outbound,
subnet addressing, IMDSv2, root-disk encryption/deletion, standard CPU credits,
required AMI input, and the permitted region. GitHub Actions repeats the checks
without AWS credentials and never applies this configuration.

## Before a real deployment

A real plan/apply is a separate, explicitly authorized step. Even with
enable_host=false, apply creates the network. Review account identity, zone
availability, CIDR overlap, permissions, costs, duration, and cleanup ownership.
The different CIDR does not automatically prove absence of overlap.

The optional host requires an explicit Amazon-owned AL2023 x86-64 AMI verified
in the intended region. Input validation checks the ID format only. SSM Agent
must be installed and running in that AMI. Host operator session permissions and
the local Session Manager plugin are separate requirements. The attached AWS
SSM Core managed policy supports capabilities beyond interactive sessions.
The existing CloudOps deployment policy is not assumed to authorize this project.

Copy terraform.tfvars.example to a local terraform.tfvars only when preparing an
authorized plan. No credentials belong in that file. Use temporary AWS access.
Keep state, local inputs, and saved plans out of Git; secure state backups and
locking are required for collaborative operations.

## Cost and cleanup

EC2, its root disk, public IPv4, data transfer, and other AWS usage can incur
charges or consume credits. No free-tier guarantee or enforced budget cap is
provided. Stopping a host does not remove disk costs; retained addresses can also
continue to cost money. Review a saved destroy plan before executing it.

This project has no retained application data. Destroying the instance deletes
its root disk. A full destroy also removes its host IAM resources and its own
network. Never use this root to clean up CloudOps resources; preserve separate
state ownership. After any deployment cleanup, verify instance termination,
volume removal, addresses, and IAM resources directly in AWS.

## Limits

This is one subnet and an optional single host. It does not establish high
availability, a production application deployment, successful SSM connectivity,
recovery behavior, or a security audit. Live verification remains pending.

**Author:** Ismet Xani
