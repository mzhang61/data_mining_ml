variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-2"
}

variable "project" {
  description = "Short name used to prefix and tag all resources."
  type        = string
  default     = "csc555_project"
}

variable "bucket_base_name" {
  description = "Base name for the S3 data bucket. A random suffix is appended to keep it globally unique."
  type        = string
  default     = "csc555-data"
}

variable "emr_release_label" {
  description = "EMR release version (bundles Spark, Hadoop, etc.)."
  type        = string
  default     = "emr-7.12.0"
}

variable "emr_applications" {
  description = "Big-data applications to install on the cluster."
  type        = list(string)
  default     = ["Spark", "Hadoop", "Hive", "Livy", "JupyterEnterpriseGateway"]
}

variable "master_instance_type" {
  description = "EC2 instance type for the master (coordinator) node."
  type        = string
  default     = "m4.xlarge"
}

variable "core_instance_type" {
  description = "EC2 instance type for the core (worker) nodes."
  type        = string
  default     = "m4.large"
}

variable "core_instance_count" {
  description = "Number of core (worker) nodes."
  type        = number
  default     = 4
}

variable "idle_timeout_seconds" {
  description = "Auto-terminate the cluster after this many idle seconds (cost protection). 3600 = 1 hour. Range 60-604800."
  type        = number
  default     = 36000
}

variable "force_destroy_bucket" {
  description = "If true, `terraform destroy` deletes the bucket even if it still holds objects. Convenient for labs; dangerous for real data."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags merged onto every resource."
  type        = map(string)
  default     = {}
}


