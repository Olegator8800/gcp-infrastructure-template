#Настраиваем bucket для хранения сертификатов
resource "google_storage_bucket" "ssl_certificates_bucket" {
  name = "${local.project_name}-ssl-certificates-bucket"

  location = local.default_region
}
