# Create elastic beanstalk application


resource "aws_elastic_beanstalk_application" "application" {
  name = var.application_name
}

# Create elastic beanstalk Environment

resource "aws_elastic_beanstalk_environment" "environment" {
  name                = "${var.application_name}-${var.environment}"
  application         = aws_elastic_beanstalk_application.application.name
  solution_stack_name = var.solution_stack_name
  tier                = var.tier

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "True"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.public_subnets)
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet facing"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.min_size
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.max_size
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }
  setting {
    name      = "SERVER_PORT"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "5000"
  }
  setting {
    name      = "CLOUD_AWS_CREDENTIALS_ACCESSKEY"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = var.aws_access_key
  }
  setting {
    name      = "CLOUD_AWS_CREDENTIALS_SECRETKEY"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = var.aws_secret_key
  }
  setting {
    name      = "CLOUD_AWS_SNS_ENDPOINT"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "https://sns.${var.region}.amazonaws.com"
  }
  setting {
    name      = "CLOUD_AWS_SQS_ENDPOINT"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "https://sqs.${var.region}.amazonaws.com"
  }
  setting {
    name      = "CLOUD_AWS_LOGGING_CLOUDWATCH_ENABLED"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "true"
  }
  setting {
    name      = "SPRING_DATASOURCE_USERNAME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = aws_db_instance.rds-instance.username
  }
  setting {
    name      = "SPRING_DATASOURCE_PASSWORD"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = aws_db_instance.rds-instance.password
  }
  setting {
    name      = "SPRING_DATASOURCE_URL"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "jdbc:postgresql://${aws_db_instance.rds-instance.address}:${aws_db_instance.rds-instance.port}/${aws_db_instance.rds-instance.name}"
  }

}