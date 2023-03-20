resource "aws_codebuild_project" "build" {
  count         = var.terraform_only ? 0 : 1
  depends_on    = [aws_cloudwatch_log_group.account_provisioning_customizations]
  name          = "${var.environment_name}-${var.application_name}-build"
  description   = "Build docker for ${var.application_name}"
  build_timeout = var.build_configuration.build_timeout
  service_role  = aws_iam_role.build.arn
  tags          = local.tags

  artifacts {
    type                = "CODEPIPELINE"
    encryption_disabled = !var.build_configuration.encrypted_artifact
  }

  environment {
    compute_type                = var.build_configuration.compute_type
    image                       = var.build_configuration.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    dynamic "environment_variable" {
      for_each = local.build_envs
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.account_provisioning_customizations.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = local.build_spec
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = [aws_security_group.builder.id]
  }
}

resource "aws_codebuild_project" "terraform_apply" {
  depends_on    = [aws_cloudwatch_log_group.account_provisioning_customizations]
  name          = "${var.environment_name}-${var.application_name}-terraform-apply"
  description   = "Apply Terraform"
  build_timeout = var.build_configuration.build_timeout
  service_role  = aws_iam_role.build.arn
  tags          = local.tags
  artifacts {
    type                = "CODEPIPELINE"
    encryption_disabled = !var.build_configuration.encrypted_artifact
  }

  environment {
    compute_type                = var.build_configuration.compute_type
    image                       = var.build_configuration.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = local.build_envs
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.account_provisioning_customizations.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.custom_backend_template != "" ? var.custom_backend_template : local.default_terraform_spec
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = [aws_security_group.builder.id]
  }

}

resource "aws_security_group" "builder" {
  name        = "${var.environment_name}-${var.application_name}-CodeBuild"
  description = "Allow CodeBuild to access resources "
  vpc_id      = var.vpc_id
  egress = [
    {
      description      = "Allow all outbound traffic by default"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  tags = merge(local.tags, {
    Name = "Build"
  })
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "account_provisioning_customizations" {
  name              = "/aws/codebuild/${var.environment_name}/${var.application_name}/build-logs"
  retention_in_days = var.logs_retention_in_days
  tags              = local.tags
}
