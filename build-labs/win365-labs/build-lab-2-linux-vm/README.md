# Build Lab 2

## Overview
In this lab you will learn how to deploy a Linux virtual machine in GCP. You will then learn how to generate SSH keys and connect to the instance.

## Getting started
To complete this lab you should have completed Build Lab 1 as we will deploy the Linux virtual machines into the networks you created.

## Creating a Linux Virtual Machine
1. In your local repository create a file called `vms.tf`

2. To create the Linux [compute instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) insert the following code block
   ```
    resource "google_compute_instance" "linux_vm" {
        name         = "my-linux-vm"
        machine_type = "e2-micro"
        zone         = "europe-west2-b"

        boot_disk {
            initialize_params {
                image = "ubuntu-os-cloud/ubuntu-2204-lts"
            }
        }

        shielded_instance_config {
          enable_secure_boot = true
        }

        network_interface {
            network    = google_compute_network.vpc_network.name
            subnetwork = google_compute_subnetwork.linux_subnet.name
            access_config {
                // Creates ephemeral public IP
            }
        }
    }
   ```
   **Bonus**: If you completed the extension of Build lab 1 try adding you region variable to this with `"${var.region}-b"`

   **Note that the shielded_instance_config block is required by LBG policies. If you remove this from your deployment, it will not deploy and will error with a policy violation error.**

   Here we are creating an e2-micro machine type which is the smallest and cheapest compute instance available on GCP.

   We have also selected an Ubuntu 18 LTS image for the instance as it is a free Linux distribution. This is an [LTS (Long Term Support)](https://ubuntu.com/blog/what-is-an-ubuntu-lts-release) release of the Ubuntu distribution which means that this version of Ubuntu will be updated and patched regularly making it more secure than a non-LTS release.

   **Bonus:** There are many other images we could have selected! Try running the below command in your terminal to see what other images are available
   ```
   gcloud compute images list
   ```

3. When we connect to the Linux VM via SSH we will need the external IP so that we can provide our local machine an address to connect to.
We can see the external IP by looking at our compute instance in the GCP console. But it is more convenient to output it into the terminal with a [terraform output](https://developer.hashicorp.com/terraform/language/values/outputs).

   Create a file called `outputs.tf` and insert the following code block
   ```
    output "linux_external_ip" {
        value = google_compute_instance.linux_vm.network_interface.0.access_config.0.nat_ip
    }
   ```
   When you run `terraform apply`, any outputs specified in the `outputs.tf` file will be visible in the console. When we run `terraform apply`, as we have specified the external IP of our compute instance in `outputs.tf`, it will be outputted in the terminal when the apply is complete.

4. To check that the compute instance is configured correctly run
   ```
   terraform plan
   ```
   When you are happy and wish to provision the instance run
   ```
   terraform apply
   ```

5. You can now see your instance in the GCP console if you go to Compute Engine


## Establishing an SSH connection to the Linux VM
1. In the previous lab we configured a [target tag](https://cloud.google.com/vpc/docs/add-remove-network-tags) in our firewall rule that will allow SSH traffic to any resource with the tag "allow-ssh". To configure the firewall rule to apply to our compute instance we need add this tag to it. Insert the following line of code into the compute instance resource block underneath `zone`
   ```
   tags = ["allow-ssh"]
   ```

2. To connect to our Linux VM we will need to generate an [SSH key pair](https://cloud.google.com/compute/docs/connect/create-ssh-keys).
Open a new terminal outside your code editor and ensure that you are in the root directory of your machine (cd \). Then run the following line if you don't already have a .ssh folder there.
   ```
   mkdir .ssh
   ```
   This will create a .ssh directory for you to store your SSH key pairs
   Then to generate your key pair run the following command in your terminal
   ```
   ssh-keygen -t rsa -f \.ssh\myKeyFile -C testUser -b 2048
   ```
   You will then be prompted to enter a passphrase for your private key and confirm it. It is good practice to add a passphrase as it makes your private key more secure and it is often a requirement set by organisations to connect to their servers. However for this lab it is not required and you can simply press enter twice.

   Once this has run it will create two files: myKeyFile (the private key) and myKeyFile.pub (the public key) in the .ssh directory

3. To authenticate your connection over SSH to your Linux machine it will need the public key of your key pair. We can do this by adding the public key file to our terraform code. But first we will need to retrieve the contents of your public key file. In your terminal run the following command:
   ```
   type \.ssh\myKeyFile.pub
   ```
   This will output the contents of the public key file into the terminal. Copy the entire contents of the file from `ssh-rsa` to `testUser` inclusive.

4. Add the following code into your compute instance resource block and replace "YOUR KEY FILE HERE" with the contents of your public key file
   ```
    metadata = {
        ssh-keys = "testUser:YOUR KEY FILE HERE"
    }
   ```
   This adds the user testUser to the machine and allows this user to connect to the instance if their machine has the corresponding private key to the public key on the machine.

5. Exit the external terminal and go back to the VS Code terminal. To add the "allow-ssh" tag and public key to your compute instance in GCP run the fol
   ```
   terraform plan
   ```
   ```
   terraform apply
   ```

6. You are now ready to connect to your VM! Copy the external IP from the Terraform output of your previous `terraform apply` in the terminal and insert it in the following command. Then run   it in the terminal.
   ```
   ssh -i \.ssh\myKeyFile testUser@<EXTERNAL IP>
   ```
   If you see `The authenticity of host _ can't be established`, type yes to continue connecting.
   When you have successfully connected you should be able to see a welcome message and `testUser@my-linux-vm`

7. Now exit the Linux VM by typing "exit" then press enter.

8. Run step 6 again to enter the VM and you should now see "Last login" and an IP address. Take note of this IP address.
   NOTE: When working with VM's, its important to restrict access as much as possible using the source ranges tag. We first use 0.0.0.0/0 which opens up the VM's access from any IP. We can't restrict the VM initially as LBG routes through proxies, meaning that your IP and the IP that accesses the VM will be different. Once you've connected, you will see the actual IP that is used to connect to the VM. We then update the source ranges to restrict to only our IP.

9. With the IP you just took note of go back to the network.tf file in the Terraform code. Under the resource of "google_compute_firewall" in both "allow_ssh" and "allow_rdp" where it says     "source_ranges", input your copied IP replacing "0.0.0.0/0". Be sure to add a "/0" on to the end of your IP. EG: "12.34.56.78/0".

 ```
    resource "google_compute_firewall" "allow_ssh" {
      name    = "allow-ssh"
      network = google_compute_network.vpc_network.name

      allow {
        protocol = "tcp"
        ports    = ["22"]
      }
      target_tags   = ["allow-ssh"]
      source_ranges = ["YOUR IP HERE/0"]
    }

    resource "google_compute_firewall" "allow_rdp" {
      name    = "allow-rdp"
      network = google_compute_network.vpc_network.name

      allow {
        protocol = "tcp"
        ports    = ["3389"]
      }
      target_tags   = ["allow-rdp"]
      source_ranges = ["YOUR IP HERE/0"]
    }

   ```

10. Run Terraform apply again to ensure the new changes have been deployed.

11. SSH back into the Linux VM using the same command from step 6.
   ```
   ssh -i \.ssh\myKeyFile testUser@<EXTERNAL IP>
   ```

12. Now you are connected to you Linux VM you can run on it from your local machine. Try running the following command to output the version of Linux on the instance
   ```
   lsb_release -a
   ```

## Other methods of connecting
GCP also allows you to connect via SSH to your virtual machine using gcloud. Try entering the following command in your terminal
```
gcloud compute ssh my-linux-vm
```
This will create a new ssh key pair and ask you for a passphrase (not required). It then connects to your VM as your Google user and you should see `Firstname.Lastname@my-linux-vm`

## Lab extension
### Terraform Dependencies
As you completed this lab you may have wondered how Terraform decides to order the creation of resources. It does this by examining your configuration for **implicit** dependencies. Inspect the code below
```
resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
  auto_create_subnetworks = false
}

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
You can see in the subnet resource we configure the subnet to be part of our VPC network with `google_compute_network.vpc_network.id`. This creates an **implicit** dependency as for the subnet to be created in the VPC the VPC has to exist first. This gives Terraform the ordering of VPC, then the subnet.

However sometimes the dependency on another resource may not be implied in our configuration. For example when we created our VM before we could SSH to it we needed to have the firewall rule in place to allow the connection. There was no way for Terraform to know this from our code so we should make the dependency **explicit**. An **explicit** dependency is declared with the `depends_on` argument like below:
```
resource "google_compute_instance" "linux_vm" {
  name         = "my-linux-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-b"

  tags = ["allow-ssh"]

  shielded_instance_config {
    enable_secure_boot = true
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.linux_subnet.name
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "testUser:${file("~/.ssh/myKeyFile.pub")}"
  }
  depends_on = [google_compute_firewall.allow_ssh]
}
```
This means that Terraform must complete the creation of the firewall rule before the creation of the Linux VM can start to be created (i.e. they cannot be created in tandem). Try adding the `depends_on` argument in different parts of your code and recreating all your infrastructure (you will need to run a `terraform destroy` then a `terraform apply`) and watch the output in the terminal. You will see how the `depends_on` argument impacts the order Terraform creates the instances.


The lack of an explicit dependency didn't cause an issue for us in this lab as when we tried our SSH connection the firewall rule creation was already complete. However in scenarios where the creation of a resource may fail if another has not finished creating, it is important to use the depends_on argument to ensure that Terraform doesn't error out.
