resource "aws_vpc" "us-east-vpc" {
  cidr_block = "10.0.0.0/16"
  provider = aws
  enable_dns_hostnames = true
}

resource "aws_vpc" "sa-east-vpc" {
  cidr_block = "10.0.0.0/16"
  provider = aws.brasil
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "us-gw" {
  vpc_id = "${aws_vpc.us-east-vpc.id}"
  provider = aws
}

resource "aws_internet_gateway" "sa-gw" {
  vpc_id = "${aws_vpc.sa-east-vpc.id}"
  provider = aws.brasil
}

resource "aws_subnet" "us-ec2-subnet" {
  cidr_block        = "10.0.0.0/24"
  vpc_id            = "${aws_vpc.us-east-vpc.id}"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch  = true

}

resource "aws_subnet" "sa-ec2-subnet" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = "${aws_vpc.sa-east-vpc.id}"
  availability_zone = "sa-east-1a"
  map_public_ip_on_launch  = true
  provider = aws.brasil

}

resource "aws_subnet" "db_subnet001" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = "${aws_vpc.sa-east-vpc.id}"
  availability_zone = "sa-east-1b"
  map_public_ip_on_launch  = true
  provider = aws.brasil

}

resource "aws_subnet" "db_subnet002" {
  cidr_block        = "10.0.3.0/24"
  vpc_id            = "${aws_vpc.sa-east-vpc.id}"
  availability_zone = "sa-east-1c"
  map_public_ip_on_launch  = true
  provider = aws.brasil

}


resource "aws_db_subnet_group" "db-sa" {
  name       = "db-sa"
  subnet_ids = [aws_subnet.db_subnet001.id , aws_subnet.db_subnet002.id]
  provider = aws.brasil
}

resource "aws_subnet" "sa-lb-subnet" {
  cidr_block        = "10.0.4.0/24"
  vpc_id            = "${aws_vpc.sa-east-vpc.id}"
  availability_zone = "sa-east-1c"
  provider = aws.brasil
}

resource "aws_subnet" "sa-lb-subnet2" {
  cidr_block        = "10.0.5.0/24"
  vpc_id            = "${aws_vpc.sa-east-vpc.id}"
  availability_zone = "sa-east-1c"
  provider = aws.brasil
}

resource "aws_security_group" "us-ec2sg" {
  name = "us-ec2sg"
  provider = aws
  vpc_id = "${aws_vpc.us-east-vpc.id}"
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}


resource "aws_security_group" "sa-ec2sg" {
  name = "sa-ec2sg"
  provider = aws.brasil
  vpc_id = "${aws_vpc.sa-east-vpc.id}"
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "sa-rdssg" {
  name = "sa-rdssg"
  provider = aws.brasil
  vpc_id = "${aws_vpc.sa-east-vpc.id}"
  ingress {
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "sa-lbsg" {
  name = "sa-lbsg"
  provider = aws.brasil
  vpc_id = "${aws_vpc.sa-east-vpc.id}"
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 3306
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_instance" "server1" {
  ami           = "ami-006dcf34c09e50022"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.us-ec2-subnet.id}"
  provider = aws
}

resource "aws_instance" "server2" {
  ami           = "ami-01d7394b0795186bc"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.sa-ec2-subnet.id}"
  provider = aws.brasil
}

resource "aws_db_instance" "post-bd" {
  identifier             = "education"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.1"
  username               = "edu"
  password               = "${var.db_password}"
  db_subnet_group_name   = aws_db_subnet_group.db-sa.name
  vpc_security_group_ids = [aws_security_group.sa-rdssg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
  provider = aws.brasil
}

resource "aws_lb" "lb-sa" {
  name               = "lb-sa"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.sa-ec2-subnet.id}", "${aws_subnet.db_subnet002.id}"]
  enable_deletion_protection = false
  provider = aws.brasil

}