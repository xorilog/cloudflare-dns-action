provider "cloudflare" {
  version = "~> 1.9"
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

resource "cloudflare_record" "record" {
  domain = "${var.cloudflare_zone}"
  name   = "${var.record_name}"
  value  = "${var.record_value}"
  type   = "${var.record_type}"
  ttl    = "${var.record_ttl}"
}