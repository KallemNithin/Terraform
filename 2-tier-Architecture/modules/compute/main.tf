provider "aws" {
  region = "us-east-1"
}

# Latest Amazon Linux 2023 AMI (resolved via SSM, always current)
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "onetier" {
  vpc_id = var.vpc_id
  name = "${var.project_name}-sg"

  ingress {
    description= "http"
    from_port = 80
    to_port = 80
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress  {
    description= "ssh"
    from_port = 22
    to_port = 22
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow All ports"
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "name" {
  count = length(var.public_subnet_cidrs)

  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = var.public_subnet_ids[count.index]

  vpc_security_group_ids = [
    aws_security_group.onetier.id
  ]

  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-jumpbox-${var.availability_zone[count.index]}"
  }
}

resource "aws_launch_template" "app" {
  instance_type = var.instance_type
  image_id = data.aws_ssm_parameter.al2023.value
  key_name = var.key_name
  name_prefix = "app-lt-"
  vpc_security_group_ids = [aws_security_group.onetier.id]

  user_data =  base64encode(<<-EOF
    #!/bin/bash
    dnf install -y nginx
    echo "Hello from $(hostname -f) in $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
      Role = "app"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "app" {
    vpc_zone_identifier = var.private_subnet_ids
    min_size = var.min
    max_size = var.max
    desired_capacity = var.desired

    health_check_type = "EC2"
    health_check_grace_period = 120

    launch_template {
        id      = aws_launch_template.app.id
        version = "$Latest"
    }

    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 74
        }
    }

    tag {
    key                 = "Name"
    value               = "app-asg-instance"
    propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "tracking" {
  name = "cpu-tracking"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75
  }
}