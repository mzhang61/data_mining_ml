# ---------------------------------------------------------------------------
# EMR needs two IAM identities:
#
#   1. SERVICE role  - lets the EMR service itself provision and manage the
#                      cluster (launch EC2, create default security groups...).
#   2. EC2 role      - the identity the cluster's EC2 instances assume. This is
#                      what actually reads from and writes to our S3 bucket.
#
# Granting (2) access to the data bucket is the *permissions* half of tying
# EMR and S3 together. See the inline policy near the bottom.
# ---------------------------------------------------------------------------

# ============================ 1. EMR service role ==========================
data "aws_iam_policy_document" "emr_service_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "emr_service" {
  name               = "${local.name}-emr-service-role"
  assume_role_policy = data.aws_iam_policy_document.emr_service_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "emr_service" {
  role       = aws_iam_role.emr_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

# ===================== 2. EC2 instance role + profile ======================
data "aws_iam_policy_document" "emr_ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "emr_ec2" {
  name               = "${local.name}-emr-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.emr_ec2_assume.json
  tags               = local.common_tags
}

# Baseline permissions the cluster's instances need to operate.
resource "aws_iam_role_policy_attachment" "emr_ec2_managed" {
  role       = aws_iam_role.emr_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

# ----------------------------------------------------------------------------
# Explicitly scope read/write on our bucket to the
# cluster's instance role. Least-privilege access to exactly this data lake.
# ----------------------------------------------------------------------------
data "aws_iam_policy_document" "emr_ec2_bucket" {
  statement {
    sid       = "ListTheBucket"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.data.arn]
  }

  statement {
    sid = "ReadWriteObjects"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.data.arn}/*"]
  }
}

resource "aws_iam_role_policy" "emr_ec2_bucket" {
  name   = "${local.name}-bucket-access"
  role   = aws_iam_role.emr_ec2.id
  policy = data.aws_iam_policy_document.emr_ec2_bucket.json
}

# EMR attaches an instance *profile* (not a role directly) to its EC2 nodes.
resource "aws_iam_instance_profile" "emr_ec2" {
  name = "${local.name}-emr-ec2-profile"
  role = aws_iam_role.emr_ec2.name
  tags = local.common_tags
}
