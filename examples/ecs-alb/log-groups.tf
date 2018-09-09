resource "aws_cloudwatch_log_group" "ecs" {
  name = "tf-ecs-group/ecs-agent"
}

resource "aws_cloudwatch_log_group" "nginx" {
  name = "tf-ecs-group/server-nginx"
}

resource "aws_cloudwatch_log_group" "php" {
  name = "tf-ecs-group/php-app"
}
