# Build Lab 1
## Overview
In this lab you will learn how to deploy a VPC with two subnets and firewall rules to allow SSH and RDP connections to resources in these networks. This build lab is a prerequisite to build lab 2 and 3.

## Getting Started

1. This repository already has Terraform configured to deploy into your GCP project. Take a look at the following code in `provider.tf`
   ```
    terraform {
        required_providers {
            google = {
            source  = "hashicorp/google"
            version = "~> 4.0.0"
        }
      }
    }
    ```
    The `required_providers` block tells Terraform which [provider](https://developer.hashicorp.com/terraform/language/providers) and version it needs to use. In this case we will be using the [GCP provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).

    The following `provider` block is where you can configure which project Terraform should deploy to.
    ```
    provider "google" {
        project = var.project_id
    }
    ```
    `var.project_id` is a variable which is defined in the `variables.tf`. You can learn more about Terraform variables in this lab's extension.

## Creating a VPC and subnets
1. In the root of your local repository create a file called `networks.tf`
   Terraform makes it easy to segment your work into logical components by creating files to group associated resources together. We are going to use this file for all our network resources so it makes sense to group them in a file. This will make it easier for you and others to follow your code.

2. To create a [VPC](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) insert the following code block in `networks.tf`
   ```
    resource "google_compute_network" "vpc_network" {
        name = "vpc-network"
        auto_create_subnetworks = false
    }
   ```
   This will create a VPC in your project with the name "vpc-network". As we want to create our own subnet with have set the argument "auto_create_subnetworks" to false.

3. To test that your VPC is configured correctly run
   ```
   terraform plan
   ```
   This will show you if you have any syntax errors and a plan of what will be provisioned in your GCP project. To learn more about terraform plan, see [here](https://developer.hashicorp.com/terraform/cli/commands/plan)

4. To create the Linux [subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) insert the following code block into `networks.tf`
   ```
    resource "google_compute_subnetwork" "linux_subnet" {
        name          = "linux-subnetwork"
        ip_cidr_range = "10.0.0.0/24"
        region        = "europe-west2"
        network       = google_compute_network.vpc_network.id
        log_config {
          aggregation_interval = "INTERVAL_5_SEC"
          flow_sampling        = 0.5
          metadata             = "INCLUDE_ALL_METADATA"
        }
    }
   ```
   This will create a subnet called "linux-subnetwork" within the VPC we have just declared. We have referenced the VPC with `google_compute_network.vpc_network.id` which fetches the ID of the VPC resource. The `log_config` block is required by LBG for security purposes. The aggregation interval toggle the aggregation interval for collecting flow logs. The flow sampling rate is the sampling rate of PC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. Metadata configures whether metadata fields should be added to the reported VPC flow logs. You can find out more from the [official documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork).

5. To create the Windows subnet insert the following code block into `networks.tf`
   ```
    resource "google_compute_subnetwork" "windows_subnet" {
        name          = "windows-subnetwork"
        ip_cidr_range = "10.1.0.0/24"
        region        = "europe-west2"
        network       = google_compute_network.vpc_network.id
        log_config {
          aggregation_interval = "INTERVAL_5_SEC"
          flow_sampling        = 0.5
          metadata             = "INCLUDE_ALL_METADATA"
        }
    }
   ```

6. To test the subnets are configured correctly run
   ```
   terraform plan
   ```
   If you are happy with the plan output run
   ```
   terraform apply
   ```
   When  prompted type "yes" to execute the apply. This will provision the VPC and subnets in your GCP project. To learn more about terraform apply, please see [here](https://developer.hashicorp.com/terraform/cli/commands/apply)

7. To check that your resources have deployed once Terraform apply has finished running, go to the GCP console -> VPC Networks. You should be able to see the VPC network called `vpc-network` that you deployed with Terraform. Click on this and you should be able to see the 2 subnetworks you deployed.

## Creating firewall rules
1. To allow SSH and RDP access into these networks we need to create a [firewall](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) rule. To do this insert the following code blocks into `networks.tf`
   ```
    resource "google_compute_firewall" "allow_ssh" {
      name    = "allow-ssh"
      network = google_compute_network.vpc_network.name

      allow {
        protocol = "tcp"
        ports    = ["22"]
      }
      target_tags   = ["allow-ssh"]
      source_ranges = ["0.0.0.0/0"]
    }

    resource "google_compute_firewall" "allow_rdp" {
      name    = "allow-rdp"
      network = google_compute_network.vpc_network.name

      allow {
        protocol = "tcp"
        ports    = ["3389"]
      }
      target_tags   = ["allow-rdp"]
      source_ranges = ["0.0.0.0/0"]
    }

   ```
   This will allow SSH and RDP traffic from anywhere into your subnets to any resource with the tag "allow-ssh" or "allow-rdp". This will be important for the next build labs.
2. To create the firewall rule run
   ```
   terraform plan
   ```
   ```
   terraform apply
   ```
3. You can check that the firewall rule has deployed correctly by going to the GCP console -> Firewall. You should be able to see 2 new firewalls called `allow-ssh` and `allow-rdp`

## Lab Extension
### Adding Variables
[Terraform input variables](https://developer.hashicorp.com/terraform/language/values/variables) can be used in your code to prevent duplication. We have created both subnets in the same region and so we have entered that value twice. But if we want to expand the code it is highly likely we will deploy more resources to this region and have to enter this value many more times increasing the risk we may enter it wrong. To prevent this we can use a variable for our region
1. Open the file `variables.tf` in your local repository

2. Look at the following code block and uncomment it so there are no longer # next to each line of code
   ```
    variable "region" {
        description = "The default GCP region to deploy resources to"
        type        = string
        default     = "europe-west2"
    }
   ```
   This declares the region variable for your Terraform directory. You can add a description to variables in Terraform which greatly improves the clarity of your code. For this variable the default argument has been set to "europe-west2". This tells Terraform to use this value for the variable region unless another value is provided.

3. In the `networks.tf` file replace any "europe-west2" strings with `var.region` like below
   ```
    resource "google_compute_subnetwork" "linux_subnet" {
        name          = "linux-subnetwork"
        ip_cidr_range = "10.0.0.0/24"
        region        = var.region
        network       = google_compute_network.vpc_network.id
        log_config {
          aggregation_interval = "INTERVAL_5_SEC"
          flow_sampling        = 0.5
          metadata             = "INCLUDE_ALL_METADATA"
        }
    }
   ```

4. When you run a plan again you will see that there are no changes to make as the region will be the same.
   ```
   terraform plan
   ```

5. If we wanted to change the region there are two different ways we could provide Terraform a new value
   1. We can pass the new value in when we run a terraform plan or apply in the terminal
      ```
      terraform plan -var region="us-central1"
      ```
      This is a useful way of passing in a small number of variables at run time
    2. We can create a `.tfvars` file and provide the value in there. Create a file called `terraform.tfvars` file and insert the following line
       ```
       region="us-central1"
       ```
       Then run this line in the terminal
       ```
       terraform plan -var-file="terraform.tfvars"
       ```
       A `.tfvars` file can be very useful when you want to pass in a group of variables to Terraform at run time. For example you could have a `.tfvars` file for each environment to pass through different values for each one.


     **Note: If you change the region, ensure to change it back to europe-west2 before continuing onto the next lab.**
