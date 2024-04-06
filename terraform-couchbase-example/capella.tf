terraform {
  required_providers {
    couchbase-capella = {
      source  = "registry.terraform.io/couchbasecloud/couchbase-capella"
    }
  }
}
 
# Configure the Couchbase Capella Provider using predefined variables
provider "couchbase-capella" {
    authentication_token = var.auth_token
    host = ""
}
 
# Create example project resource
resource "couchbase-capella_project" "new_project" {
     organization_id = var.organization_id
     name            = "Terraform Demo Project"
     description     = "A Capella Project that will host a Capella cluster"
}

# Stores the project name in an output variable.
# Can be viewed using `terraform output project` command
output "project" {
  value = couchbase-capella_project.new_project.name
}

# Create  cluster resource
resource "couchbase-capella_cluster" "new_cluster" {
  organization_id = var.organization_id
  project_id      = couchbase-capella_project.new_project.id
  name            = "Terraform Demo Cluster"
  description     = "Test cluster created with Terraform"
  cloud_provider = {
    type   = "aws"
    region = "us-east-1"
    cidr   = "192.168.10.0/23"
  }
  couchbase_server = {
    version = "7.2"
  }
  service_groups = [
    {
      node = {
        compute = {
          cpu = 4
          ram = 16
        }
        disk = {
          storage = 50
          type    = "io2"
          iops    = 5000
        }
      }
      num_of_nodes = 3
      services     = ["data", "index", "query"]
    }
  ]
  availability = {
    "type" : "multi"
  }
  support = {
    plan     = "developer pro"
    timezone = "PT"
  }
}

# Stores the cluster details in an output variable.
# Can be viewed using `terraform output cluster` command
output "cluster" {
  value = couchbase-capella_cluster.new_cluster
}

# Create bucket in cluster
resource "couchbase-capella_bucket" "new_bucket" {
  name                       = "terraform_bucket"
  organization_id            = var.organization_id
  project_id                 = couchbase-capella_project.new_project.id
  cluster_id                 = couchbase-capella_cluster.new_cluster.id
  type                       = "couchbase"
  storage_backend            = "couchstore"
  memory_allocation_in_mb    = 100
  bucket_conflict_resolution = "seqno"
  durability_level           = "none"
  replicas                   = 1
  flush                      = false
  time_to_live_in_seconds    = 0
  eviction_policy            = "fullEviction"
}

# Stores the bucket name in an output variable.
# Can be viewed using `terraform output bucket` command
output "bucket" {
  value = couchbase-capella_bucket.new_bucket.name
}

# Create  cluster resource 2
resource "couchbase-capella_cluster" "new_cluster_mumbai" {
  organization_id = var.organization_id
  project_id      = couchbase-capella_project.new_project.id
  name            = "Terraform Demo Cluster Mumbai"
  description     = "Test cluster created with Terraform"
  cloud_provider = {
    type   = "aws"
    region = "ap-south-1"
    cidr   = "192.168.12.0/23"
  }
  couchbase_server = {
    version = "7.2"
  }
  service_groups = [
    {
      node = {
        compute = {
          cpu = 4
          ram = 16
        }
        disk = {
          storage = 50
          type    = "io2"
          iops    = 5000
        }
      }
      num_of_nodes = 3
      services     = ["data", "index", "query"]
    }
  ]
  availability = {
    "type" : "multi"
  }
  support = {
    plan     = "developer pro"
    timezone = "PT"
  }
}

# Stores the cluster details in an output variable.
# Can be viewed using `terraform output cluster` command
output "cluster_2" {
  value = couchbase-capella_cluster.new_cluster_mumbai
}

# Create bucket in cluster
resource "couchbase-capella_bucket" "new_bucket_mumbai" {
  name                       = "terraform_bucket"
  organization_id            = var.organization_id
  project_id                 = couchbase-capella_project.new_project.id
  cluster_id                 = couchbase-capella_cluster.new_cluster_mumbai.id
  type                       = "couchbase"
  storage_backend            = "couchstore"
  memory_allocation_in_mb    = 100
  bucket_conflict_resolution = "seqno"
  durability_level           = "none"
  replicas                   = 1
  flush                      = false
  time_to_live_in_seconds    = 0
  eviction_policy            = "fullEviction"
}

# Stores the bucket name in an output variable.
# Can be viewed using `terraform output bucket` command
output "bucket_2" {
  value = couchbase-capella_bucket.new_bucket_mumbai.name
}