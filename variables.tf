variable "alb_arn" {
  description = "The ARN of the application load balancer."
  type        = string
}

variable "domains" {
  default     = []
  description = ""
  type        = list(string)
}

variable "tg_arn" {
  description = "ARN of the target group for which this listener is for."
  type        = string
}
