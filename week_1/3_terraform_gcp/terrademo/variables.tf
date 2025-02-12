variable "Location" {
  description = "Project Location"
  default = "EU"
}


variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default = "demo_dataset"
}


variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default = "terraform-demo-450422-terra-bucket"
}


variable "gcs_storage_class" {
  description = "Bucket Storage Class"
    default = "STANDARD"
}