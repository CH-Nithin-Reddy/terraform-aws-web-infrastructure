#################################
# VPC
#################################

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr

  tags = {
    Name = "my-vpc"
  }
}

#################################
# Subnets
#################################

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

#################################
# Internet Gateway
#################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-igw"
  }
}

#################################
# Route Table
#################################

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

#################################
# Route Table Association
#################################

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

#################################
# Security Group (SSH + HTTP)
#################################

resource "aws_security_group" "webSg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "web-sg"
  }
}

# SSH Port 22
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.webSg.id
  cidr_ipv4         = "0.0.0.0/0"

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# HTTP Port 80
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.webSg.id
  cidr_ipv4         = "0.0.0.0/0"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

# Outbound
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.webSg.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "-1"
}

#################################
# S3 Bucket
#################################

resource "aws_s3_bucket" "example" {
  bucket = "nithin-terraform-project-2026-001"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.example.id
  acl    = "private"
}

#################################
# EC2 Instance 1
#################################

resource "aws_instance" "webserver1" {

  ami           = "ami-0ec10929233384c7f"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.sub1.id

  vpc_security_group_ids = [
    aws_security_group.webSg.id
  ]

  user_data = file("userdata.sh")

  tags = {
    Name = "Web-Server-1"
  }
}

#################################
# EC2 Instance 2
#################################

resource "aws_instance" "webserver2" {

  ami           = "ami-0ec10929233384c7f"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.sub2.id

  vpc_security_group_ids = [
    aws_security_group.webSg.id
  ]

  user_data = file("userdata1.sh")

  tags = {
    Name = "Web-Server-2"
  }
}
#################################
# Create Application Load Balancer
#################################

resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.webSg.id]

  subnets = [
    aws_subnet.sub1.id,
    aws_subnet.sub2.id
  ]

  tags = {
    Name = "web-alb"
  }
}

#################################
# Target Group
#################################

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

  tags = {
    Name = "web-target-group"
  }
}

#################################
# Attach EC2 Instances
#################################

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

#################################
# Listener
#################################

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

#################################
# Output Load Balancer DNS
#################################

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}