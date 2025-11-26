terraform {
  backend "gcs" {
    bucket = "state-gke-bucket"
    prefix = "terraform/state"
  }
}
