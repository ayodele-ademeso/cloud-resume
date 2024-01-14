provider "aws" {
#   access_key = "ASIAWNIA3PDEMYIFMSXX"
#   secret_key = "o38RtLZS32BUSlWh2yHPJdEzRNLw+u/xHuLt7MCL"
  region     = "us-east-1"
  assume_role {
    role_arn    = "arn:aws:iam::440772819144:role/ayodele-itc-terraform-role" #${var.assume_role}
    external_id = "050124"
  }
}