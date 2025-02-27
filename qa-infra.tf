
# 🔹 Create VPC
resource "aws_vpc" "qa_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "qa-vpc"
  }
}

# 🔹 Create Two Subnets (in different AZs)
resource "aws_subnet" "qa_subnet_1" {
  vpc_id            = aws_vpc.qa_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "qa-subnet-1"
  }
}

resource "aws_subnet" "qa_subnet_2" {
  vpc_id            = aws_vpc.qa_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "qa-subnet-2"
  }
}

# 🔹 Create an Internet Gateway for Public Access
resource "aws_internet_gateway" "qa_gw" {
  vpc_id = aws_vpc.qa_vpc.id

  tags = {
    Name = "qa-gateway"
  }
}

# 🔹 Route Table for Public Subnet
resource "aws_route_table" "qa_route_table" {
  vpc_id = aws_vpc.qa_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.qa_gw.id
  }

  tags = {
    Name = "qa-route-table"
  }
}

# 🔹 Associate Subnet with Route Table
resource "aws_route_table_association" "qa_assoc_1" {
  subnet_id      = aws_subnet.qa_subnet_1.id
  route_table_id = aws_route_table.qa_route_table.id
}

resource "aws_route_table_association" "qa_assoc_2" {
  subnet_id      = aws_subnet.qa_subnet_2.id
  route_table_id = aws_route_table.qa_route_table.id
}

# 🔹 Security Group for EC2 & RDS
resource "aws_security_group" "qa_sg" {
  vpc_id = aws_vpc.qa_vpc.id

  # Allow SSH (22) Access from Anywhere (Modify for Security)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (80) Access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow All Outbound Traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "qa-security-group"
  }
}

# 🔹 Get Latest Amazon Linux 2 AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#
resource "aws_instance" "qa_server" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.qa_subnet_1.id
  vpc_security_group_ids = [aws_security_group.qa_sg.id]  # ✅ Correct way

  tags = {
    Name = "qa-${terraform.workspace}-server"
  }
}


# 🔹 DB Subnet Group (Needs 2 AZs)
resource "aws_db_subnet_group" "qa_db_subnet_group" {
  name       = "qa-db-subnet-group"
  subnet_ids = [aws_subnet.qa_subnet_1.id, aws_subnet.qa_subnet_2.id]

  tags = {
    Name = "qa-db-subnet-group"
  }
}

# 🔹 RDS Database Instance
resource "aws_db_instance" "qa_db" {
  identifier            = "qa-${terraform.workspace}-db"
  engine                = "mysql"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  username             = "admin"
  password             = "password123"
  vpc_security_group_ids = [aws_security_group.qa_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.qa_db_subnet_group.name
  skip_final_snapshot   = true
  publicly_accessible   = false

  tags = {
    Name = "qa-db"
  }
}
