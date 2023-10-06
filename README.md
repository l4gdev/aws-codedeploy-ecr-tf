# terraform-aws-codedeploy-ecr
This module creates a terraform-enabled deployment pipeline using codebuild and codepipeline.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_cloudwatch_log_group.account_provisioning_customizations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_codebuild_project.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) (resource)
- [aws_codebuild_project.terraform_apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) (resource)
- [aws_codepipeline.codestar_account_provisioning_customizations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) (resource)
- [aws_iam_role.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy.codebuild_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_iam_role_policy.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_security_group.builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) (data source)
- [aws_s3_bucket.bucket_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_application_name"></a> [application\_name](#input\_application\_name)

Description: Name of your service, should be unique across repository.

Type: `string`

### <a name="input_build_envs"></a> [build\_envs](#input\_build\_envs)

Description: key -> value definition for example {REGION: "eu-west-1"}

Type: `map(string)`

### <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name)

Description: Name of your deployment environment. For example; sandbox, staging, production.

Type: `string`

### <a name="input_pipeline_artifacts_bucket"></a> [pipeline\_artifacts\_bucket](#input\_pipeline\_artifacts\_bucket)

Description: n/a

Type: `string`

### <a name="input_region"></a> [region](#input\_region)

Description: AWS region

Type: `string`

### <a name="input_repository"></a> [repository](#input\_repository)

Description: n/a

Type:

```hcl
object({
    name   = string,
    branch = string
  })
```

### <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)

Description: n/a

Type: `list(string)`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: n/a

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_build_configuration"></a> [build\_configuration](#input\_build\_configuration)

Description: n/a

Type:

```hcl
object({

    build_timeout      = string
    compute_type       = string
    type               = optional(string, "LINUX_CONTAINER")
    image              = optional(string, "aws/codebuild/amazonlinux2-x86_64-standard:5.0")
    terraform_version  = string
    encrypted_artifact = bool

  })
```

Default:

```json
{
  "build_timeout": "300",
  "compute_type": "BUILD_GENERAL1_SMALL",
  "encrypted_artifact": true,
  "image": "aws/codebuild/amazonlinux2-x86_64-standard:5.0",
  "terraform_version": "1.2.6",
  "type": "LINUX_CONTAINER"
}
```

### <a name="input_codestar_connection_arn"></a> [codestar\_connection\_arn](#input\_codestar\_connection\_arn)

Description: An ARN for AWS codestar connection (eg for github)

Type: `string`

Default: `null`

### <a name="input_custom_backend_template"></a> [custom\_backend\_template](#input\_custom\_backend\_template)

Description: n/a

Type: `string`

Default: `""`

### <a name="input_custom_backend_template_variables"></a> [custom\_backend\_template\_variables](#input\_custom\_backend\_template\_variables)

Description: Custom variables to be passed to the backend template {"tfstate\_role\_arn": "arn:aws:iam::123456789012:role/terraform-state-role"}

Type: `map(string)`

Default: `{}`

### <a name="input_custom_build_spec"></a> [custom\_build\_spec](#input\_custom\_build\_spec)

Description: AWS codebuild build custom spec

Type: `string`

Default: `""`

### <a name="input_logs_retention_in_days"></a> [logs\_retention\_in\_days](#input\_logs\_retention\_in\_days)

Description: Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.

Type: `number`

Default: `0`

### <a name="input_resource_to_deploy"></a> [resource\_to\_deploy](#input\_resource\_to\_deploy)

Description: List of resources that will be targeted by terraform. For example: ['aws\_instance.test', 'module.app']

Type: `list(string)`

Default: `[]`

### <a name="input_roles_allowed_to_assume"></a> [roles\_allowed\_to\_assume](#input\_roles\_allowed\_to\_assume)

Description: n/a

Type: `list(string)`

Default: `[]`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Additional tags (e.g. '{'BusinessUnit': 'XYZ'}`). Neither the tag keys nor the tag values will be modified by this module.`

Type: `map(string)`

Default: `{}`

### <a name="input_terraform_directory"></a> [terraform\_directory](#input\_terraform\_directory)

Description: The directory where the terraform files are located

Type: `string`

Default: `""`

### <a name="input_terraform_only"></a> [terraform\_only](#input\_terraform\_only)

Description: n/a

Type: `bool`

Default: `false`

### <a name="input_tf_backend_region"></a> [tf\_backend\_region](#input\_tf\_backend\_region)

Description: AWS region where the terraform state will be stored by default the same as the region of the pipeline

Type: `string`

Default: `""`

### <a name="input_tfstate_bucket"></a> [tfstate\_bucket](#input\_tfstate\_bucket)

Description: Name of the bucket where the terraform state will be stored by default terraform-state-<account\_id>

Type: `string`

Default: `""`

### <a name="input_tfstate_key"></a> [tfstate\_key](#input\_tfstate\_key)

Description: Name of the key where the terraform state will be stored by default <environment\_name>/<application\_name>.tfstate

Type: `string`

Default: `""`

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
