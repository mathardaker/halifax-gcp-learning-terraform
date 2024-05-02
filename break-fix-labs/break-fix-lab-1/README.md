# Break Fix Lab 1 - VPC and subnet

## Expected outcome
The following break/fix lab should create one VPC containing one subnet.

## Task
The terraform currently fails at ``terraform init`` and ``terraform plan``. Your task is to find the bugs in the Terraform code and fix it so that the VPC and subnet are successfully created. There are a total of 3 bugs to find and fix.

## How to run this task
1. If you haven't already done so, clone this repository to your computer and open in VS Code
2. Expand this folder. Add your GCP project name to the default value of the variable "project" in variables.tf. Your project name should be in the format of "playpen-a1b2cd".  Add your workspace name to the name argument of the workspace block in providers.tf. Your workspace name should be in the format of "playpen-a1b2cd-gcp"
3. Open a terminal, and cd into this break fix lab 1 folder.

4. Log into GCP with the following command
   ```
   gcloud auth login
   ```
   This will open a browser window and ask you to log into your Google account. Then run
   ```
   gcloud config set project <YOUR PROJECT NAME>
   ```
5. To authenticate with Terraform Cloud run
   ```
   terraform login
   ```
   Then when prompted type "yes"
   This should open a window for you to log into Terraform Cloud. Click "Sign in with SSO" near the bottom of the page. On the next page type in your Organization name "lbg-cloud-platform" and hit next. You will then be asked to sign into your dev account.

   When you reach your account you will be prompted to create an API token. Click create token and copy the token generated. Go back to your terminal and where it says enter value paste the API token you copied.
6. To install the providers and initialise the directory run
   ```
   terraform init
   ```
7. To print out a plan of the resources that will be provisioned run
   ```
   terraform plan
   ```
8. If you are happy with the plan and wish to provision the resources run
   ```
   terraform apply
   ```
   When prompted type 'yes' to execute the apply
9. The VPC containing one subnet should now be provisioned in GCP

## Finishing up
When you are finished with the lab run
   ```
   terraform destroy
   ```
   When prompted type 'yes' to destroy the resources you have provisioned
