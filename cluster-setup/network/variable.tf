variable "aws_default_tags" {
  type = map(string)
  default = {
    "Purpose" = "Demo"
    "Creator" = "tanmay"
  }
}
variable "vpc_cidr" {
  type    = string
  default = "10.30.224.0/20"
}
variable "utility_a_cidr" {
  type    = string
  default = "10.30.224.128/25"
}
variable "utility_b_cidr" {
  type    = string
  default = "10.30.225.128/25"
}

variable "app_a_cidr" {
  type    = string
  default = "10.30.226.128/25"
}

variable "app_b_cidr" {
  type    = string
  default = "10.30.227.128/25"
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "aws_az_a" {
  type = string
  default = "ap-south-1a"
}
variable "aws_az_b" {
  type = string
  default = "ap-south-1b"
}




