resource "google_compute_network" "private_vpc" {
  name = "private-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_network" {
  name          = "private-network"
  ip_cidr_range = "10.10.0.0/20"
  private_ip_google_access = false
  network       = google_compute_network.private_vpc.self_link
}

# resource "google_compute_route" "apis_route" {
#   name        = "apis-route"
#   dest_range  = "199.36.153.4/30"
#   next_hop_gateway = "default-internet-gateway"
#   network     = google_compute_network.private_vpc.self_link
# }
