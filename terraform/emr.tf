resource "aws_emr_cluster" "spark" {
  name          = "${local.name}-spark"
  release_label = var.emr_release_label
  applications  = var.emr_applications
  log_uri       = "s3://${aws_s3_bucket.data.id}/logs/"

  ec2_attributes {
    subnet_id = local.subnet_id

    # The instance profile carries the S3 permissions
    # defined in iam.tf, so Spark jobs can reach the bucket.
    instance_profile = aws_iam_instance_profile.emr_ec2.arn

    # Security groups intentionally omitted -> EMR creates and manages its
    # own default master/slave security groups for us.
  }

  master_instance_group {
    instance_type  = var.master_instance_type
    instance_count = 1
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count
  }

  service_role = aws_iam_role.emr_service.arn

  # Cost protection: terminate automatically once the cluster sits idle.
  auto_termination_policy {
    idle_timeout = var.idle_timeout_seconds
  }

  keep_job_flow_alive_when_no_steps = true

  tags = local.common_tags
}

