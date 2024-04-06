---

# Terraform Provider for Capella

## Prerequisites

- **Terraform**: Version 1.5.2 or higher
- **Go**: Version 1.20 or higher
- **A Capella paid account**

## Authentication & Authorization

All operations by the Capella Terraform provider are authenticated and authorized via a Capella Management API key. In a production environment, consider using HashiCorp Vault or a Cloud Service Provider's secrets manager (e.g., AWS Secrets Manager) to manage API keys. For this demonstration, we will set the credentials in a local environment variables file.

1. Create a file named `variables.tf` and add the following variable definitions:

   ```hcl
   variable "organization_id" {
     description = "Capella Organization ID"
   }

   variable "auth_token" {
     description = "Authentication API Key"
   }
   ```

2. Create a file named `terraform.template.tfvars` and add the following lines, specifying the values of key variables:

   ```hcl
   auth_token = "<replace-with-v4-api-key-secret>"
   organization_id = "<replace-with-the-oid-of-your-tenant>"
   ```

   - `auth_token`: Create the API key via Capella UI or the management API, depending on the scope of the resources managed.
   - `organization_id`: Obtain this from the organization management API or from the Capella UI's browser URL (look for the "oid" parameter).

## Configuration for Sample Deployment

As mentioned earlier, the GitHub repo of the Provider has an extensive set of configuration templates. Here, we use a simple example to demonstrate the provider's use in creating a profile, deploying a cluster, and a bucket within the cluster.

1. Create a file named `capella.tf` and add the following configuration:

   ```hcl
   terraform {
     required_providers {
       couchbase-capella = {
         source  = "registry.terraform.io/couchbasecloud/couchbase-capella"
       }
     }
   }

   provider "couchbase-capella" {
       authentication_token = var.auth_token
   }

   resource "couchbase-capella_project" "new_project" {
        organization_id = var.organization_id
        name            = "Terraform Demo Project"
        description     = "A Capella Project that will host a Capella cluster"
   }

   output "project" {
     value = couchbase-capella_project.new_project.name
   }

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

   output "cluster" {
     value = couchbase-capella_cluster.new_cluster
   }

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

   output "bucket" {
     value = couchbase-capella_bucket.new_bucket.name
   }
   ```

## Deploy and Manage Resources

Use standard Terraform commands to initialize and deploy the resources:

1. **Initialize Terraform**:

   ```bash
   terraform init
   ```

2. **Review the Terraform plan**:

   ```bash
   terraform plan -var-file terraform.template.tfvars
   ```

3. **Execute the Terraform plan**:

   ```bash
   terraform apply -var-file terraform.template.tfvars
   ```

   You should see output similar to the following, indicating that the resources are being deployed:

   ```bash
   capella_project.new_project: Creating...
   capella_project.new_project: Creation complete after 0s [id=c9151819-2f75-41dd-b944-7e33d12163ea]
   capella_cluster.new_cluster: Creating...
   capella_cluster.new_cluster: Still creating... [10s elapsed]
   ...
   capella_cluster.new_cluster: Creation complete after 3m1s [id=29ebb043-xxxx-xxxx-xxxx-xxxxxxxxxxxx]
   capella_bucket.new_bucket: Creating...
   capella_bucket.new_bucket: Creation complete after 0s [id=dGVycmFmb3JtXXXXXXXXXX=]
   Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
   ```

4. **Get the current state of the resources**:

   ```bash
   terraform state list
   ```

---

Feel free to adjust the formatting or add more details as needed!