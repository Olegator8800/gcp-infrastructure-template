#Настраиваем nat gateway для доступа в интернет

#резервация ip адреса для доступа в интернет инстансов
resource "google_compute_address" "vpc_nat_ip" {
  name = "vpc-nat-ip-${count.index}"
  address_type = "EXTERNAL"
  count = 2
}

resource "google_compute_router" "vpc_nat_router" {
  name = "vpc-nat-router"
  network = google_compute_network.private_vpc.self_link
}

resource "google_compute_router_nat" "vpc_nat" {
  name = "vpc-nat"
  router = google_compute_router.vpc_nat_router.name
  region = google_compute_router.vpc_nat_router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = google_compute_address.vpc_nat_ip.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name = google_compute_subnetwork.private_network.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
