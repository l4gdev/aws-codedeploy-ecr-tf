locals {
  tags = merge({
    Environment = var.environment_name
    Service     = var.application_name
  }, var.tags)
  default_build_envs = {
    AWS_DEFAULT_REGION = data.aws_region.current.name
    AWS_ACCOUNT_ID     = tostring(data.aws_caller_identity.current.account_id)
  }


  build_envs = merge(merge(local.default_build_envs, var.build_envs), local.tags)
  build_spec = var.custom_build_spec == "" ? file("${path.module}/buildspecs/docker-build.yml") : var.custom_build_spec
  default_terraform_spec = templatefile("${path.module}/buildspecs/terraform-runner.yml", {
    TF_VERSION                      = var.build_configuration.terraform_version
    IMAGE_DETAILS_PATH_COPY_COMMAND = var.terraform_only ? "echo \"Terraform only run nothing to copy\"" : "cp ..${var.terraform_directory == "" ? "" : "/.."}/01/imageDetail.json ."
    TF_BACKEND_REGION               = var.tf_backend_region != "" ? var.tf_backend_region : data.aws_region.current.name
    REGION                          = var.region
    TF_S3_BUCKET                    = var.tfstate_bucket != "" ? var.tfstate_bucket : "terraform-state-${data.aws_caller_identity.current.account_id}"
    TF_S3_KEY                       = var.tfstate_key != "" ? var.tfstate_key : "${var.environment_name}/${var.application_name}.tfstate"
    SERVICE                         = var.application_name
    ENVIRONMENT                     = var.environment_name
    TAGS                            = jsonencode(var.tags)
    TARGETS                         = join(" ", [for t in var.resource_to_deploy : "-target=${t}"])
    CUSTOM_BACKEND_TEMPLATE_VARS    = join(" ", [for n, v in var.custom_backend_template_variables : "-D ${n}=${v}"])
    TERRAFORM_DIRECTORY             = var.terraform_directory
    TERRAFORM_ARGS                  = var.terraform_only ? "" : "-var-file=imageDetail.json"
  })
}
