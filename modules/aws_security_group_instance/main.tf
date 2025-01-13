resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Allow TCP/8080 & TCP/22"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 443 from our public IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 3000 from our public IP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 3100 from our public IP"
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 5002 from our public IP"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 5002 from our public IP"
    from_port   = 5002
    to_port     = 5002
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 5044 from our public IP"
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 5601 from our public IP"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 6379 from our public IP"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 3000 from our public IP"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }

  ingress {
    description = "Allow anyone on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 9100 from our public IP"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 9100 from our public IP"
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 9200 from our public IP"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow 9200 from our public IP"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 9100 from our public IP"
    from_port   = 9999
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow anyone on port 8080"
    from_port   = 32100
    to_port     = 32100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow traffic from subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet_1]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow 22 from our public IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 3000 from our public IP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 3000 from our public IP"
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 5002 from our public IP"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 5002 from our public IP"
    from_port   = 5002
    to_port     = 5002
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 5044 from our public IP"
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 5601 from our public IP"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 6379 from our public IP"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow anyone on port 8080"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow anyone on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow 9100 from our public IP"
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 9100 from our public IP"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 9100 from our public IP"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 9100 from our public IP"
    from_port   = 8000
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 9200 from our public IP"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow 9999 from our public IP"
    from_port   = 9999
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }
  egress {
    description = "Allow anyone on port 32100"
    from_port   = 32100
    to_port     = 32100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}
