# Настраиваем kubernates кластер
# See https://github.com/jetstack/terraform-google-gke-cluster/blob/master/main.tf
# See https://github.com/daaain/terraform-kubernetes-on-gcp/tree/master/example2-kubernetes-terraform
# See https://github.com/oracle/terraform-kubernetes-installer/tree/master/kubernetes/kubeconfig
# See https://dzone.com/articles/build-a-kubernetes-cluster-on-gcp-with-terraform
# See https://aperogeek.fr/kubernetes-deployment-with-terraform/

# Получаем доступную версию
data "google_container_engine_versions" "gke_engine_versions" {
  location = local.default_zone
  version_prefix = "1.15.11-gke.5"
}

# k8s мастер
resource "google_container_cluster" "k8s_cluster" {
  name     = "k8s-cluster"
  location = "europe-north1-b"
  # location = local.default_region
  # node_locations = [
  #   "europe-north1-a",
  #   "europe-north1-b",
  #   "europe-north1-c"
  # ]
  min_master_version = data.google_container_engine_versions.gke_engine_versions.latest_node_version

  # private_cluster_config {
  #   enable_private_endpoint = false
  #   enable_private_nodes = true

  #   master_ipv4_cidr_block = "10.16.0.0/14"
  # }

  network = google_compute_network.private_vpc.self_link
  subnetwork = google_compute_subnetwork.private_network.self_link

  remove_default_node_pool = true
  initial_node_count = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = google_compute_subnetwork.private_network.ip_cidr_range
      display_name = "ACCESS_PRIVATE_VPC"
    }
  }
}

# k8s ноды кластера
resource "google_container_node_pool" "k8s_nodes" {
  name       = "k8s-node-pool"
  # location   = local.default_zone
  location   = "europe-north1-b"
  cluster    = google_container_cluster.k8s_cluster.name

  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  upgrade_settings {
    max_surge = 2
    max_unavailable = 0
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    tags = ["cluster-node"]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

# Конфигурация самого кластера
module "k8s_cluster" {
  source = "./k8s-cluster"

  k8s_master_url = google_container_cluster.k8s_cluster.endpoint
  k8s_access_token = data.google_client_config.default.access_token
  k8s_cluster_ca_certificate = google_container_cluster.k8s_cluster.master_auth.0.cluster_ca_certificate
}

# Выводим для конфигов
output "k8s_access_token" {
  value = data.google_client_config.default.access_token
  sensitive = true
}

output "k8s_cluster_ca_certificate" {
  value = base64decode(google_container_cluster.k8s_cluster.master_auth.0.cluster_ca_certificate)
  sensitive = true
}


output "k8s_master_ip" {
  value = google_container_cluster.k8s_cluster.endpoint
  sensitive = true
}
