provider "google" {
  project = local.project_name
  region  = local.default_region
  zone    = local.default_zone
}

data "google_client_config" "default" {
}
