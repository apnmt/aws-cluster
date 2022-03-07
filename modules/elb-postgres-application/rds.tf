resource "aws_security_group" "rds" {
  name   = "${var.application_name}-rds-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.application_name}-rds-${var.environment}"
  subnet_ids = var.private_subnets

  tags = {
    Environment = var.environment
  }
}

resource "random_string" "rds-db-password" {
  length  = 32
  upper   = true
  number  = true
  special = false
}

resource "aws_db_instance" "rds-instance" {
  identifier             = "${var.application_name}-db-${var.environment}"
  name                   = var.application_name
  instance_class         = var.db_instance_type
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12.9"
  skip_final_snapshot    = true
  publicly_accessible    = true
  username               = var.application_name
  password               = random_string.rds-db-password.result
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}