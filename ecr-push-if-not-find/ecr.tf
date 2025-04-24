resource "aws_ecr_repository" "foo_ecr_repository" {
  name                 = "playground/foo"
  image_tag_mutability = "MUTABLE"
}
