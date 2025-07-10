data "aws_iam_policy_document" "step_fn_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

#resource "aws_iam_role" "step_fn_role" {
#  name               = "step_fn_role"
#  assume_role_policy = data.aws_iam_policy_document.step_fn_assume_role.json
#}

resource "aws_sfn_state_machine" "etl_state_machine" {
  name     = "etl-state-machine"
  role_arn = aws_iam_role.step_fn_role.arn

  definition = templatefile("${path.module}/stfn.asl.json", {
    LAMBDA_ARN_PLACEHOLDER = aws_lambda_function.etl_function.arn
  })
}
