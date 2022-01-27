resource "aws_sns_topic" "appointment-changed" {
  name = "appointment-changed"
  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic" "service-changed" {
  name = "service-changed"
  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic" "closing-time-changed" {
  name = "closing-time-changed"
  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic" "opening-hour-changed" {
  name = "opening-hour-changed"
  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic" "working-hour-changed" {
  name = "working-hour-changed"
  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic" "organization-activation-changed" {
  name = "organization-activation-changed"
  tags = {
    Environment = var.environment
  }
}