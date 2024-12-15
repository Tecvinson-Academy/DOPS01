data "aws_vpc" "vpc_dops01" {
  id = "vpc-08fcbd2bedfbbddaa"
}

resource "aws_subnet" "dops01_subnet1" {
  vpc_id     = "vpc-08fcbd2bedfbbddaa"
  cidr_block = "192.168.128.0/19"
  availability_zone = "us-east-1c"

  tags = {
    Name = "dops01_subnet1"
  }
}

resource "aws_subnet" "dops01_subnet2" {
  vpc_id     = "vpc-08fcbd2bedfbbddaa"
  cidr_block = "192.168.160.0/19"
  availability_zone = "us-east-1d"

  tags = {
    Name = "dops01_subnet2"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.dops01_subnet1.id, aws_subnet.dops01_subnet2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  vpc_id = data.aws_vpc.vpc_dops01.id

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.vpc_dops01.cidr_block]
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  identifier           = "DOPS01-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "dops01"
  password             = "1234admin"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  depends_on = [ aws_security_group.rds_sg, aws_db_subnet_group.db_subnet_group ]
}

resource "aws_ecr_repository" "fe_dops01" {
  name                 = "fe_dops01"
  image_tag_mutability = "MUTABLE"
}

