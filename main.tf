locals {
  anywhere      = "0.0.0.0/0"
  all_ports     = "-1"
  http_port     = 80
  tcp_protocol  = "tcp"
  http_protocol = "HTTP"
}

data "aws_vpc" "default" { // GET request
  default = true
}

data "aws_subnet" "az_a" {
  availability_zone = "ap-southeast-1a"
  default_for_az    = true
}

data "aws_subnet" "az_b" {
  availability_zone = "ap-southeast-1b"
  default_for_az    = true
}

# Application Load Balancer
resource "aws_alb" "nginx_lb" {
  name               = "app-loadbalancer"
  internal           = false
  load_balancer_type = var.lb_type
  security_groups    = [aws_security_group.lb_security_gp.id]
  subnets            = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]

  enable_deletion_protection = false


  tags = {
    Name = "app-loadbalancer"
  }
}


# Target Group
resource "aws_lb_target_group" "app_tg" {
  name        = "nginx-target-group"
  target_type = var.target_type
  port        = local.http_port
  protocol    = local.http_protocol
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "nginx-target-group"
  }
}


# ALB Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_alb.nginx_lb.arn
  port              = local.http_port
  protocol          = local.http_protocol

  default_action {
    type             = var.routing_action
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



# Launch Template for EC2 Instances
resource "aws_launch_template" "app_template" {
  name_prefix            = "nginx-launch-template"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_security_gp.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "nginx-instance-#{aws:instance-id}" # Auto assigns EC2 instance ID
    }
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    # Update package lists
    sudo apt update -y

    # Install Nginx
    sudo apt install -y nginx

    # Ensure Nginx is started and enabled
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Optional: Create a custom welcome page
    #echo "<html><body><h1>Welcome to Nginx on Ubuntu AWS Auto Scaling!</h1></body></html>" | sudo tee /var/www/html/index.html

    # Ensure proper permissions
    sudo chmod 644 /var/www/html/index.html
  EOF
  )

}

resource "aws_autoscaling_group" "app_asg" {
  name                = "nginx-asg"
  min_size            = var.min_instances
  max_size            = var.max_instances
  desired_capacity    = var.desired_capacity
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  vpc_zone_identifier = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
  launch_template {
    id      = aws_launch_template.app_template.id
    version = var.template_verison
  }

}
