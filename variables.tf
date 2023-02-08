variable "application_name" {
  type        = string
  description = "Name of your service, should be unique across repository."
}

variable "environment_name" {
  type        = string
  description = "Name of your deployment environment. For example; sandbox, staging, production."
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "logs_retention_in_days" {
  type        = number
  default     = 0
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
}

variable "repository" {
  type = object({
    name   = string,
    branch = string
  })
}

variable "build_configuration" {
  type = object({

    build_timeout      = string
    compute_type       = string
    image              = string
    terraform_version  = string
    encrypted_artifact = bool

  })
  default = {
    build_timeout      = "300"
    compute_type       = "BUILD_GENERAL1_SMALL"
    encrypted_artifact = true
    image              = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    terraform_version  = "1.2.6"
  }
}

variable "custom_build_spec" {
  type        = string
  default     = ""
  description = "AWS codebuild build custom spec"
}

variable "build_envs" {
  type        = map(string)
  description = "key -> value definition for example {REGION: \"eu-west-1\"}"
}

variable "pipeline_artifacts_bucket" {
  type = string
}

variable "codestar_connection_arn" {
  type        = string
  default     = null
  nullable    = true
  description = "An ARN for AWS codestar connection (eg for github)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. '{'BusinessUnit': 'XYZ'}`). Neither the tag keys nor the tag values will be modified by this module."
}


variable "resource_to_deploy" {
  type        = list(string)
  default     = []
  description = "List of resources that will be targeted by terraform. For example: ['aws_instance.test', 'module.app']"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "tfstate_bucket" {
  type        = string
  default     = ""
  description = "Name of the bucket where the terraform state will be stored by default terraform-state-<account_id>"
}
variable "tfstate_key" {
  type        = string
  default     = ""
  description = "Name of the key where the terraform state will be stored by default <environment_name>/<application_name>.tfstate"
}

variable "tf_backend_region" {
  type        = string
  default     = ""
  description = "AWS region where the terraform state will be stored by default the same as the region of the pipeline"
}

variable "custom_backend_template" {
  type    = string
  default = ""
}

variable "custom_backend_template_variables" {
  type        = map(string)
  description = "Custom variables to be passed to the backend template {\"tfstate_role_arn\": \"arn:aws:iam::123456789012:role/terraform-state-role\"}"
  default     = {}
}

variable "terraform_directory" {
  default     = ""
  type        = string
  description = "The directory where the terraform files are located"
}

variable "terraform_only" {
  type    = bool
  default = false
}