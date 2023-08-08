resource "aws_iam_role" "codebuild_app_role" {
  name = format("%s_%s_app_codebuild_role", var.Environment, var.app_name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_app_policy" {
  role = aws_iam_role.codebuild_app_role.name

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [{
			"Effect": "Allow",
			"Resource": "*",
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			]
		},
		{
			"Effect": "Allow",
			"Resource": "*",
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:GetObjectVersion",
				"s3:GetBucketAcl",
				"s3:GetBucketLocation"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"codebuild:CreateReportGroup",
				"codebuild:CreateReport",
				"codebuild:UpdateReport",
				"codebuild:BatchPutTestCases",
				"codebuild:BatchPutCodeCoverages"
			],
			"Resource": "*"
		},
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"secretsmanager:ListSecrets",
				"secretsmanager:GetSecretValue"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:*",
				"s3-object-lambda:*"
			],
			"Resource": "*"
		}
	]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "CodeBuildPolicyAttach" {
  role       = aws_iam_role.codebuild_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "CodeBuildPolicyAttach1" {
  role       = aws_iam_role.codebuild_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "CodeBuildPolicyAttach2" {
  role       = aws_iam_role.codebuild_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_codebuild_project" "app" {
  name          = format("%s_%s_codebuild_app", var.Environment, var.app_name)
  description   = "App_codebuild_project"
  build_timeout = "15"
  service_role  = aws_iam_role.codebuild_app_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:6.0"
    type         = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.group_name
      stream_name = var.stream_name
    }
  }

  source {
    type            = "GITHUB"
    location        = var.source_location
    git_clone_depth = 0

    git_submodules_config {
      fetch_submodules = true
    }
  }
}

resource "aws_codedeploy_app" "app" {
  compute_platform = "Server"
  name             = format("%s_%s_codedeploy_app", var.Environment, var.app_name)
}

resource "aws_codedeploy_deployment_group" "app_deploy_group" {
  app_name              = resource.aws_codedeploy_app.app.name
  deployment_group_name = aws_codedeploy_app.app.name
  service_role_arn      = resource.aws_iam_role.codedeploy_role.arn
  autoscaling_groups    = [module.asg.autoscaling_group_name]
}
resource "aws_iam_role" "codedeploy_role" {
  name = format("%s_%s_codedeploy_role", var.Environment, var.app_name)

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "codedeploy_policy" {
  name = format("%s_%s_app_codedeploy_policy", var.Environment, var.app_name)
  role = aws_iam_role.codedeploy_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:EnableMetricsCollection",
                "autoscaling:DescribePolicies",
                "autoscaling:DescribeScheduledActions",
                "autoscaling:DescribeNotificationConfigurations",
                "autoscaling:SuspendProcesses",
                "autoscaling:ResumeProcesses",
                "autoscaling:AttachLoadBalancers",
                "autoscaling:AttachLoadBalancerTargetGroups",
                "autoscaling:PutScalingPolicy",
                "autoscaling:PutScheduledUpdateGroupAction",
                "autoscaling:PutNotificationConfiguration",
                "autoscaling:PutWarmPool",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DeleteAutoScalingGroup",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:TerminateInstances",
                "tag:GetResources",
                "sns:Publish",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeInstanceHealth",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "*"
        },
       {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole",
                "ec2:CreateTags",
                "ec2:RunInstances"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "CodeDeployPolicyAttach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "CodeDeployPolicyAttach1" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "CodeDeployPolicyAttach2" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

resource "aws_codepipeline" "codepipeline" {
  name     = format("%s_%s_codepipeline_app", var.Environment, var.app_name)
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline-bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = [var.output_artifacts]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.app.arn
        FullRepositoryId = var.FullRepositoryId
        BranchName       = var.BranchName
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = [var.output_artifacts]
      output_artifacts = ["${var.app_name}_build_output"]
      version          = "1"

      configuration = {
        ProjectName = format("%s_%s_codebuild_app", var.Environment, var.app_name)
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["${var.app_name}_build_output"]
      version         = "1"

      configuration = {
        ApplicationName     = resource.aws_codedeploy_app.app.name
        DeploymentGroupName = resource.aws_codedeploy_deployment_group.app_deploy_group.deployment_group_name
      }
    }
  }
}

resource "aws_codestarconnections_connection" "app" {
  name          = format("%s_%s_csconnections", var.Environment, var.app_name)
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "codepipeline-bucket" {
  bucket = format("%s-%s-codepipeline-bucket", var.Environment, var.app_name)
}


resource "aws_iam_role" "codepipeline_role" {
  name = format("%s_%s_app_codepipeline_role", var.Environment, var.app_name)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "codepipeline_policy" {
  name = format("%s_%s_app_codepipeline_policy", var.Environment, var.app_name)
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:GetObjectVersion",
				"s3:GetBucketVersioning",
				"s3:PutObjectAcl",
				"s3:PutObject"
			],
			"Resource": [
				"${aws_s3_bucket.codepipeline-bucket.arn}",
				"${aws_s3_bucket.codepipeline-bucket.arn}/*"
			]
		},
		{
			"Action": [
				"iam:PassRole"
			],
			"Resource": "*",
			"Effect": "Allow",
			"Condition": {
				"StringEqualsIfExists": {
					"iam:PassedToService": [
						"cloudformation.amazonaws.com",
						"elasticbeanstalk.amazonaws.com",
						"ec2.amazonaws.com",
						"ecs-tasks.amazonaws.com"
					]
				}
			}
		},
		{
			"Action": [
				"codestar-connections:UseConnection"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"codecommit:CancelUploadArchive",
				"codecommit:GetBranch",
				"codecommit:GetCommit",
				"codecommit:GetRepository",
				"codecommit:GetUploadArchiveStatus",
				"codecommit:UploadArchive"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Effect": "Allow",
			"Action": [
				"codebuild:BatchGetBuilds",
				"codebuild:StartBuild"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"devicefarm:ListProjects",
				"devicefarm:ListDevicePools",
				"devicefarm:GetRun",
				"devicefarm:GetUpload",
				"devicefarm:CreateUpload",
				"devicefarm:ScheduleRun"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"servicecatalog:ListProvisioningArtifacts",
				"servicecatalog:CreateProvisioningArtifact",
				"servicecatalog:DescribeProvisioningArtifact",
				"servicecatalog:DeleteProvisioningArtifact",
				"servicecatalog:UpdateProduct"
			],
			"Resource": "*"
		},
		{
			"Action": [
				"codedeploy:*"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Effect": "Allow",
			"Action": [
				"appconfig:StartDeployment",
				"appconfig:StopDeployment",
				"appconfig:GetDeployment"
			],
			"Resource": "*"
		}
	]
}
EOF
}