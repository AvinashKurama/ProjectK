resource "aws_lb_target_group" "alb-Test" {
  name     = "myLB"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC_1.id
}

resource "aws_lb" "Test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.Pub_1.id, aws_subnet.Prv_2.id]

  enable_deletion_protection = true


  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.Test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-Test.arn
  }
}

resource "aws_lb_target_group_attachment" "test1" {
  target_group_arn = aws_lb_target_group.alb-Test.arn
  target_id        = aws_instance.web.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "test2" {
  target_group_arn = aws_lb_target_group.alb-Test.arn
  target_id        = aws_instance.Dev.id
  port             = 80
}

