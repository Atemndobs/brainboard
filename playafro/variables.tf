variable "env_tag" {
  description = <<EOT
Tag for determining what enviromnment this resource is deployed to 
dev, stage, prod
EOT
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
}

