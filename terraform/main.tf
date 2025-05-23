# Configuração do provider AWS
provider "aws" {
  region = "us-east-1"
}

# Criação da VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lab-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab-igw"
  }
}

# Sub-redes Públicas
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab-public-subnet-1"
    Type = "Public"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab-public-subnet-2"
    Type = "Public"
  }
}

# Sub-redes Privadas
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "lab-private-subnet-1"
    Type = "Private"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "lab-private-subnet-2"
    Type = "Private"
  }
}

# Tabela de rotas para sub-redes públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "lab-public-rt"
  }
}

# Tabela de rotas para sub-redes privadas
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab-private-rt"
  }
}

# Associações das sub-redes públicas com a tabela de rotas pública
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Associações das sub-redes privadas com a tabela de rotas privada
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# Security Group para a EC2
resource "aws_security_group" "ec2_sg" {
  name_prefix = "lab-ec2-sg"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab-ec2-sg"
  }
}

# Buscar dinamicamente a AMI do Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "description"
    values = ["Amazon Linux 2023 AMI*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# IAM Role para CodeDeploy
resource "aws_iam_role" "ec2_codedeploy_role" {
  name = "EC2CodeDeployRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "EC2CodeDeployRole"
  }
}

# Política para acessar S3
resource "aws_iam_role_policy_attachment" "s3_readonly_policy" {
  role       = aws_iam_role.ec2_codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_codedeploy_profile" {
  name = "EC2CodeDeployProfile"
  role = aws_iam_role.ec2_codedeploy_role.name
}

# Instância EC2 na sub-rede pública 2 (us-east-1b)
resource "aws_instance" "lab_ec2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_codedeploy_profile.name
  key_name               = "key"  # Sua chave existente
  
  # User data MÍNIMO - apenas Instance Connect e Apache
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              
              # Instalar EC2 Instance Connect
              dnf install -y ec2-instance-connect
              systemctl enable ec2-instance-connect
              systemctl start ec2-instance-connect
              
              # Instalar Apache apenas
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from EC2 in lab-vpc!</h1>" > /var/www/html/index.html
              
              # Log básico
              echo "=== LOG DE INSTALAÇÃO ===" >> /var/log/user-data.log
              echo "Data e hora: $(date)" >> /var/log/user-data.log
              echo "Instance Connect: INSTALADO" >> /var/log/user-data.log
              echo "Apache: $(systemctl is-active httpd)" >> /var/log/user-data.log
              echo "Node.js: NÃO INSTALADO - para instalação manual" >> /var/log/user-data.log
              echo "CodeDeploy: NÃO INSTALADO - para instalação manual" >> /var/log/user-data.log
              echo "=========================" >> /var/log/user-data.log
              EOF

  tags = {
    Name = "labServer"
  }
}

# Outputs
output "vpc_id" {
  value = aws_vpc.lab_vpc.id
}

output "ec2_public_ip" {
  value = aws_instance.lab_ec2.public_ip
}

output "ssh_connection_command" {
  value = "ssh -i key.pem ec2-user@${aws_instance.lab_ec2.public_ip}"
}

output "web_url" {
  value = "http://${aws_instance.lab_ec2.public_ip}"
  description = "URL para acessar a página web"
}

output "selected_ami" {
  value = data.aws_ami.amazon_linux_2023.id
  description = "AMI selecionada"
}