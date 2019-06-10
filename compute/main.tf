variable "node_count" {
  default = "3"
 }

variable "zone" {
  default ="us-west1-a"
}

variable "machine_type" {
  default = "f1-micro"
}

variable "image" {
  default ="debian-cloud/debian-9"
}
resource "google_compute_disk" "test-node-1-index-disk-" {
    count   = "${var.node_count}"
    name    = "test-node-1-index-disk-${count.index}-data"
    type    = "pd-standard"
    zone    = "${var.zone}"
    size    = "5"
}
resource "google_compute_instance" "test-node-" {
    count = "${var.node_count}"
    name = "test-node-${count.index}"
    machine_type = "${var.machine_type}"
    zone = "${var.zone}"

    boot_disk {
    initialize_params {
    image = "${var.image}"
    }
   }
    attached_disk {
        source      = "${element(google_compute_disk.test-node-1-index-disk-.*.self_link, count.index)}"
        device_name = "${element(google_compute_disk.test-node-1-index-disk-.*.name, count.index)}"
   }


    network_interface {
      network = "default"
      access_config {
        // Ephemeral IP
      }

    }
}
