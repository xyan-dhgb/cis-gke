terraform {
  backend "gcs" {
    bucket = "ENTER_BUCKET_NAME"
    prefix = "terraform/state"
  }
}