# Break Fix Lab 3 - Windows VM and RDP

## Expected outcome
The following break/fix lab should create a Windows VM you can RDP to.

## Task
The code currently fails at the `terraform plan` stage. Your task is to find and fix the bugs so that the Terraform deploys and you can RDP to the Windows VM successfully.
**Hint** There may be some things missing from the Terraform code.

## How to run this task
1. If you haven't already - clone this repository to your computer and open in VS Code
2.  Expand this folder. Add your GCP project name to the default value of the variable "project" in variables.tf. Your project name should be in the format of "playpen-a1b2cd".  Add your workspace name to the name argument of the workspace block in providers.tf. Your workspace name should be in the format of "playpen-a1b2cd-gcp"
3. Open a terminal, cd into this directory, and log into GCP with the following command
   ```
   gcloud auth login
   ```
   This will open a browser window and ask you to log into your Google account. Then run
   ```
   gcloud config set project <YOUR PROJECT NAME>
   ```
   To set your project as the default

4. To authenticate with terraform cloud run
   ```
   terraform login
   ```
   Then when prompted type "yes"
   This should open a window for you to log into Terraform Cloud. Click "Sign in with SSO" near the bottom of the page. On the next page type in your Organization name "lbg-cloud-platform" and hit next. You will then be asked to sign into your dev account.

   When you reach your account you will be prompted to create an API token. Click create token and copy the token generated. Go back to your terminal and where it says enter value paste the API token you copied.
5. To install the providers and initialise the directory run
   ```
   terraform init
   ```
6. To print out a plan of the resources that will be provisioned run
   ```
   terraform plan
   ```
7. If you are happy with the plan and wish to provision the resources run
   ```
   terraform apply
   ```
   When prompted type 'yes' to execute the apply
8. The resources should now be provisioned in GCP

## Finishing up
When you are finished with the lab run
   ```
   terraform destroy
   ```
   When prompted type 'yes' to destroy the resources you have provisioned
