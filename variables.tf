variable "aws_region" {
  description = "Region for this demonstration."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "This demonstration is scoped to us-east-1."
  }
}

variable "availability_zone" {
  description = "Verify this zone exists in the target account before deployment."
  type        = string
  default     = "us-east-1a"
  validation {
    condition     = can(regex("^us-east-1[a-z]$", var.availability_zone))
    error_message = "Use a standard availability zone in us-east-1."
  }
}

variable "enable_host" {
  description = "Opt in to billable EC2, disk, public IPv4 and host IAM resources."
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "Verified Amazon-owned AL2023 x86-64 AMI, required when the host is enabled."
  type        = string
  default     = ""
  validation {
    condition     = !var.enable_host || can(regex("^ami-([0-9a-f]{8}|[0-9a-f]{17})$", var.ami_id))
    error_message = "Enabling the host requires an explicit AMI ID; verify ownership and compatibility separately."
  }
}
