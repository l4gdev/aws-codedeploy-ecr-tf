resource "aws_iam_role" "codepipeline_role" {
  name = lower("${var.labels.tags.Environment}-${var.labels.tags.Service}-codepipeline-role")
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
    }
  )
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = lower("${var.labels.tags.Environment}-${var.labels.tags.Service}-codepipeline-policy")
  role = aws_iam_role.codepipeline_role.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:List*",
            "s3:PutObjectAcl",
            "s3:PutObject"
          ],
          "Resource" : [
            aws_s3_bucket.store.arn,
            "${aws_s3_bucket.store.arn}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "codecommit:GetBranch",
            "codecommit:GetRepository",
            "codecommit:GetCommit",
            "codecommit:GitPull",
            "codecommit:UploadArchive",
            "codecommit:GetUploadArchiveStatus",
            "codecommit:CancelUploadArchive"
          ],
          "Resource" : "arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        #        {
        #          "Effect" : "Allow",
        #          "Action" : [
        #            "kms:Decrypt",
        #            "kms:Encrypt",
        #            "kms:GenerateDataKey"
        #          ],
        #          "Resource" : var.aft_key_arn
        #        },
        {
          "Effect" : "Allow",
          "Action" : "codestar-connections:UseConnection",
          "Resource" : "*"
          }, {
          "Effect" : "Allow",
          "Action" : [
            "codebuild:StartBuild"
          ],
          "Resource" : [
            "arn:aws:codebuild:eu-west-1:${data.aws_caller_identity.current.account_id}:project/${aws_codebuild_project.build.name}"
          ]
        }
      ]
    }

  )
}


resource "aws_iam_role" "build" {
  name = lower("${var.labels.tags.Environment}-${var.labels.tags.Service}-codebuild-role")
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
    }
  )
}

resource "aws_iam_role_policy" "codebuild_role" {
  name = lower("${var.labels.tags.Environment}-${var.labels.tags.Service}-codebuild-policy")
  role = aws_iam_role.build.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNetworkInterfacePermission"
        ],
        "Resource" : [
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:List*",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        "Resource" : [
          var.s3_artifact_store,
          "${var.s3_artifact_store}/*"
        ]
      },
      #      {
      #        "Effect" : "Allow",
      #        "Action" : [
      #          "kms:Decrypt",
      #          "kms:Encrypt",
      #          "kms:GenerateDataKey"
      #        ],
      #        "Resource" : "${var.aft_key_arn}"
      #      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource" : [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codecommit:GetBranch",
          "codecommit:GetRepository",
          "codecommit:GetCommit",
          "codecommit:GitPull",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:CancelUploadArchive"
        ],
        "Resource" : "arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSAFTAdmin"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:*"
        ],
        //TODO limit perms to single repo only
        "Resource" : [
          "*"
        ]
      }
    ]
    }
  )
}


resource "aws_iam_role_policy_attachment" "admin_rights" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.build.id
}