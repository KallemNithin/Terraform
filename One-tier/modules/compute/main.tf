data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 Auto Scaling Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl enable --now httpd

    TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token"       -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    AZ=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN"       http://169.254.169.254/latest/meta-data/placement/availability-zone)

    INSTANCE_ID=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN"       http://169.254.169.254/latest/meta-data/instance-id)

    echo "<h1>${var.project_name}</h1><p>Instance: $INSTANCE_ID</p><p>Availability Zone: $AZ</p>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-instance"
    }
  }

  tags = {
    Name = "${var.project_name}-launch-template"
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.project_name}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.public_subnet_ids

  health_check_type         = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}
