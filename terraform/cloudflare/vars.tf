# Cloudflare variables
variable "cloudflare_email" {
  default = "CLOUDFLARE_EMAIL"
}

variable "cloudflare_token" {
  default = "CLOUDFLARE_TOKEN"
}

variable "record_domain" {
  default = "RECORD_DOMAIN"
}

variable "record_name" {
  default = "RECORD_NAME"
}

variable "record_value" {
  default = "RECORD_VALUE"
  type = "string"
}

variable "record_type" {
  default = "RECORD_TYPE"
}

variable "record_ttl" {
  default = 1
}