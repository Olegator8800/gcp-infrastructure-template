#Настраиваем vpn
#https://github.com/kylemanna/docker-openvpn

#резервация статичного ip адреса для vpn инстанса
resource "google_compute_address" "vpn_static_ip" {
  name = "vpn-static-ip"
  address_type = "EXTERNAL"
}

#днс запись для vpn.*
resource "google_dns_record_set" "vpn_dns_record" {
  name         = "vpn.${google_dns_managed_zone.prod_zone.dns_name}"
  managed_zone = google_dns_managed_zone.prod_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["${google_compute_address.vpn_static_ip.address}"]
}

#vpn трафик толкьо для vpn-server
resource "google_compute_firewall" "allow_vpn" {
  name    = "allow-vpn"
  network = google_compute_network.private_vpc.self_link

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["vpn-server"]
}

#ssh трафик для всех инстансов
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.private_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

#icmp для всей сети
resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = google_compute_network.private_vpc.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]

  priority = 65534
}

#весь трафик доступен внутри приватной сети
resource "google_compute_firewall" "allow_all_internal" {
  name    = "allow-all-internal"
  network = google_compute_network.private_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    google_compute_subnetwork.private_network.ip_cidr_range
  ]
}

#инстанс под vpn сервер
resource "google_compute_instance" "vpn_server" {
  name         = "vpn-server"
  machine_type = "f1-micro"
  zone = "europe-north1-b"

  tags = ["vpn-server"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.private_vpc.self_link
    subnetwork = google_compute_subnetwork.private_network.self_link

    access_config {
      nat_ip = google_compute_address.vpn_static_ip.address
    }
  }
}
