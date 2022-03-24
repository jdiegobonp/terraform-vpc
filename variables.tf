# Project variable
variable "project" {
  description = "Name of the project"
  type        = string
  default     = "challenge-2"
}

# cidr Block variable
variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

# Environment variable
variable "environment" {
  description = "Environment to deploy all resources"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "stage", "prod"], var.environment)
    error_message = "The environment name isn't validated. It was expected [dev, qa, stage or prod]."
  }
}

# Availability zones list variable
variable "az" {
  description = "A list of AZ names or ids in the region"
  type        = list(string)
}

# Public subnets variable list
variable "public_subnets" {
  description = "A list of public subnets"
  type        = list(string)
}

# Private subnets variable list
variable "private_subnets" {
  description = "A list of private subnets"
  type        = list(string)
}

# Flag to enable or disable DNS hostnames
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS"
  type        = bool
  default     = false
}

# Flag to enable or disable DNS support
variable "enable_dns_support" {
  description = "Should be true to enable DNS"
  type        = bool
  default     = true
}

# Tags variable map
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}