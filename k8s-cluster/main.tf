provider "kubernetes" {
  load_config_file = false

  host  = "https://${var.k8s_master_url}"
  token = var.k8s_access_token
  cluster_ca_certificate = base64decode(
    var.k8s_cluster_ca_certificate
  )
}
