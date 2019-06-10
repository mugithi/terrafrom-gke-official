resource "google_compute_disk" "neo4j" {
  count = 3
  name  = "test-disk${count.index}"
  type  = "pd-ssd"
  zone         = "us-west1-a"
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}


// A single Google Cloud Engine instance
resource "google_compute_instance" "neo4j" {
 name         = "neo4j-compute-instance-dev"
 machine_type = "f1-micro"
 zone         = "us-west1-a"

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }
 
 // You must include this in the compute_instance resource that has the disk attached so that the attached disk can me modified independent of the compute_instance resouce
 lifecycle {
    ignore_changes = ["attached_disk"]
  }

 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}


resource "google_compute_attached_disk" "neo4j" {
  count = 3
  disk = "${google_compute_disk.neo4j[count.index].self_link}"
  instance = "${google_compute_instance.neo4j.self_link}"
  device_name = "${count.index}" //Name which attached disk will be accessible from under /dev/disk/by-id/
}
