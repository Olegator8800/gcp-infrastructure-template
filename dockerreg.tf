#Настраиваем dockerreg
#https://docs.docker.com/registry/deploying/
#https://gist.github.com/PieterScheffers/63e4c2fd5553af8a35101b5e868a811e

#резервация статичного ip адреса для dockerreg инстанса
resource "google_compute_address" "dockerreg_static_ip" {
  name = "dockerreg-static-ip"
  subnetwork = google_compute_subnetwork.private_network.self_link
  address_type = "INTERNAL"
}

# #днс запись для dockerreg.*
resource "google_dns_record_set" "dockerreg_dns_record" {
  name         = "dockerreg.${google_dns_managed_zone.prod_zone.dns_name}"
  managed_zone = google_dns_managed_zone.prod_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["${google_compute_address.dockerreg_static_ip.address}"]
}

#Хранилище для docker образов
resource "google_storage_bucket" "dockerreg_bucket" {
  name = "${local.project_name}-dockerreg-bucket"

  location = local.default_region
}

#инстанс под dockerreg сервер
resource "google_compute_instance" "dockerreg_server" {
  name         = "dockerreg-server"
  machine_type = "g1-small"
  zone = "europe-north1-b"

  tags = [
    "docker-registry",
    "need-ssl"
  ]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata_startup_script = join("\n", [
    file("scripts/install-docker.sh")
    ,file("scripts/install-gcsfuse.sh")
    ,file("dockerreg/install-dockerreg.sh")
    ,"sudo gcsfuse ${google_storage_bucket.dockerreg_bucket.name} /home/dockerreg_bucket"
    ,"sudo gcsfuse ${google_storage_bucket.ssl_certificates_bucket.name} /home/ssl_certificates_bucket"
  ])

  service_account {
    scopes = [
      "storage-full"
    ]
  }

  network_interface {
    network = google_compute_network.private_vpc.self_link
    subnetwork = google_compute_subnetwork.private_network.self_link

    network_ip = google_compute_address.dockerreg_static_ip.address
  }
}
