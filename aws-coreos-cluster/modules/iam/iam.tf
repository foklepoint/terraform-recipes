# deployment user for elb registrations etc.

resource "aws_iam_user" "deployment" {
    name = "${var.deployment_user}"
    path = "/system/"
}

resource "aws_iam_user_policy" "deployment" {
    name = "deployment"
    user = "${aws_iam_user.deployment.name}"
    policy = "${file(\"policies/deployment_policy.json\")}"
}

resource "aws_iam_access_key" "deployment" {
    user = "${aws_iam_user.deployment.name}"

    provisioner "local-exec" {
    # generate a cloud-config file segment that installs aws deployment credentials on the target nodes. 
    command = <<CMD_DATA
cat > "${var.cloud_config_file_path}" <<EOF

  # Generated by iam.tf
  - path: /etc/aws/account.envvars
    permissions: 0644
    owner: root
    content: |
        AWS_ACCOUNT=${var.aws_account_id}
        AWS_DEFAULT_REGION=${var.aws_account_region}
        CLUSTER_NAME=${var.cluster_name}

  - path: /root/.aws/envvars
    permissions: 0600
    owner: root
    content: |
        AWS_ACCOUNT=${var.aws_account_id}
        AWS_USER=${aws_iam_user.deployment.name}
        AWS_ACCESS_KEY_ID="${aws_iam_access_key.deployment.id}"
        AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.deployment.secret}
        AWS_DEFAULT_REGION=${var.aws_account_region}
        
  - path: /root/.aws/config
    permissions: 0600
    owner: root
    content: |
        [default]
        aws_access_key_id="${aws_iam_access_key.deployment.id}"
        aws_secret_access_key=${aws_iam_access_key.deployment.secret}
        region=${var.aws_account_region}

CMD_DATA
    }
}
