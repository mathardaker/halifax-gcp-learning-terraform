## Welcome to the Learning Labs for Terraform
This repository contains the Terraform build labs, and break fix labs for the Learning Labs. To view the labs please click into the corresponding folders. Each lab has its own README containing details on how to complete the tasks. The labs found here are designed to help develop a foundational knowledge of Terraform and to provide hands on experience with creating and running Terraform code to deploy infrastructure in GCP. Please note that the playpen and the linked repository will auto-delete after 12 hours of provisioning.

### Getting Started
Depending on your device, you will follow specific setup instructions prior to beginning the labs:
- If you are completing these labs on a Dev Mac device, please follow the setup instructions under `dev-mac-setup-instructions.md`.
- If you are completing these labs on a Win365 device, please follow the setup instructions under `win365-setup-instructions.md`.

These setup instructions will guide you on how to setup and connect to your Terraform environment where you will complete the labs.

## GCP Labs
**Build Labs**
* Build Lab 1 - VPCs and subnets
* Build Lab 2 - Linux compute instance and SSH
* Build Lab 3 - Windows compute instance and RDP

**Break Fix Labs**
* Break Fix Lab 1 - Syntax errors
* Break Fix Lab 2 - Networking errors
* Break Fix Lab 3 - Networking and syntax errors

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_google"></a> [google](#requirement\_google) (~> 4.0.0)

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Required Inputs

The following input variables are required:

### <a name="input_project_id"></a> [project\_id](#input\_project\_id)

Description: The ID of the GCP project where resources will be deployed

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->