## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.account_provisioning_customizations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.terraform_apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.codestar_account_provisioning_customizations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_codestarconnections_connection.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection) | resource |
| [aws_iam_role.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codebuild_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.admin_rights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [local_file.docker_build_buildspec](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | n/a | `string` | n/a | yes |
| <a name="input_build_configuration"></a> [build\_configuration](#input\_build\_configuration) | n/a | <pre>object({<br>    build_timeout = string<br>    compute_type  = string<br>    image         = string<br>  })</pre> | <pre>{<br>  "build_timeout": "300",<br>  "compute_type": "BUILD_GENERAL1_SMALL",<br>  "image": "aws/codebuild/amazonlinux2-x86_64-standard:3.0",<br>  "terraform_version": "1.1.7"<br>}</pre> | no |
| <a name="input_build_envs"></a> [build\_envs](#input\_build\_envs) | key -> value definition for example {REGION: "eu-west-1"} | `any` | n/a | yes |
| <a name="input_custom_build_spec"></a> [custom\_build\_spec](#input\_custom\_build\_spec) | AWS codebuild build spec | `string` | `""` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | n/a | <pre>object({<br>    tags = object({<br>      Environment = string<br>      Service     = string<br>    })<br>    name = string<br>  })</pre> | n/a | yes |
| <a name="input_log_group_retention"></a> [log\_group\_retention](#input\_log\_group\_retention) | n/a | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | n/a | <pre>object({<br>    name   = string,<br>    branch = string<br>  })</pre> | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | n/a | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
