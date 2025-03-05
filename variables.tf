variable "lb_type" {
  description = "Type of Load Balancer"
  type        = string
  default     = "application"
}

variable "target_type" {
  description = "Type of Target Group"
  type        = string
  default     = "instance"
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "min_instances" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "max_instances" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "routing_action" {
  description = "Type of routing action in Load Balancer"
  type        = string
  default     = "forward"
}

variable "template_verison" {
  description = "Launch template version"
  type        = string
  default     = "$Latest"
}