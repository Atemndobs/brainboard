variable "az1" {
  type    = string
  default = "us-east-1a"
}

variable "az2" {
  type    = string
  default = "us-east-1b"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
}

