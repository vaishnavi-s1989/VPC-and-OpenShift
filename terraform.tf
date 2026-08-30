terraform {
  required_version = ">= 1.6.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.67.0"
    }
  }

  # Uncomment to use IBM Cloud Object Storage as remote state backend
  # backend "s3" {
  #   bucket                      = "terraform-state-bucket"
  #   key                         = "vpc-openshift/terraform.tfstate"
  #   region                      = "us-south"
  #   endpoint                    = "https://s3.us-south.cloud-object-storage.appdomain.cloud"
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   skip_region_validation      = true
  #   force_path_style            = true
  # }
}
