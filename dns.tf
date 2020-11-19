resource "google_dns_managed_zone" "prod_zone" {
  name        = "prod-zone"
  dns_name    = local.prod_dns_name
  description = "Prod DNS zone"
}

resource "google_dns_record_set" "cname" {
  name         = "www.${google_dns_managed_zone.prod_zone.dns_name}"
  managed_zone = google_dns_managed_zone.prod_zone.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["${google_dns_managed_zone.prod_zone.dns_name}"]
}
