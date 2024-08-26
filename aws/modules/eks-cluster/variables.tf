variable "enable_public_access" {
  type=bool
  default=false
}

variable subnets {
  type = list(string)
}

variable "name" {
  type = string
}

variable "kubernetes_version" {
  type = string
  default = null
}

variable "log_types" {
  type=list(string)
  default=["audit", "api", "authenticator","scheduler"]
}