resource "aws_iam_user" "pbondare" {
  name = "pbondare"
  tags = local.common_tags
}

resource "aws_iam_user_login_profile" "pbondare" {
  user                    = aws_iam_user.pbondare.name
  password_reset_required = true
}

resource "aws_iam_user_policy_attachment" "pbondare_readonly" {
  user       = aws_iam_user.pbondare.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

output "pbondare_password" {
  value     = aws_iam_user_login_profile.pbondare.password
  sensitive = true
}
