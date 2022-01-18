resource "aws_security_group" "documentdb" {
  name   = "${var.application_name}-documentdb-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_docdb_subnet_group" "documentdb" {
  name       = "${var.application_name}-documentdb-${var.environment}"
  subnet_ids = var.public_subnets

  tags = {
    Environment = var.environment
  }
}

resource "random_string" "documentdb-db-password" {
  length  = 32
  upper   = true
  number  = true
  special = false
}

resource "aws_docdb_cluster_instance" "service" {
  count              = 1
  identifier         = "${var.application_name}-documentdb-${var.environment}-${count.index}"
  cluster_identifier = aws_docdb_cluster.documentdb-cluster.id
  instance_class     = var.docdb_instance_type
}

resource "aws_docdb_cluster" "documentdb-cluster" {
  skip_final_snapshot             = true
  db_subnet_group_name            = aws_docdb_subnet_group.documentdb.name
  cluster_identifier              = "${var.application_name}-db-${var.environment}"
  engine                          = "docdb"
  engine_version                  = "4.0.0"
  master_username                 = var.application_name
  master_password                 = random_string.documentdb-db-password.result
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.documentdb.name
  vpc_security_group_ids          = [aws_security_group.documentdb.id]
}

resource "aws_docdb_cluster_parameter_group" "documentdb" {
  family = "docdb4.0"
  name   = "${var.application_name}-db-${var.environment}"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}
