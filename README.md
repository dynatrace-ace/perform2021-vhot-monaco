# perform2021-vhot-monaco

This repository will spin up an environment to conduct a Monaco HOT session based on VMs running in GCP.

## Contents

The following will be deployed:
- An Ubuntu VM in GCP with a public IP address
- Monaco
- k3s
- Helm
- Gitea
- Jenkins
- Dynatrace OneAgent
- Dynatrace ActiveGate for private synthetic
- An application in 3 namespaces
- A launchpad dashboard

## Using Terraform to spin up the HOT environments

At the moment, only GCP is supported with a ready-made Terraform config.

### Requirements
Terraform needs to be locally installed.
A GCP account is needed.

### Instructions

1. Prepare Service Account and download JSON key credentials in GCP.

    ```
    https://cloud.google.com/iam/docs/creating-managing-service-accounts
    ```

1. Navigate to the `terraform` folder

    ```
    $ cd microk8s/terraform
    ```

1. Create key pair for ssh authentication

    ```
    ssh-keygen -b 2048 -t rsa -f key
    ```
    Enter through the defaults.

1. Initialize terraform
    ```
    $ terraform init
    ```

1. Create a `terraform.tfvars` file inside the *terraform* folder
   It needs to contain the following as a minimum:
    
    ```
    gcloud_project    = "mygcpproject"
    gcloud_cred_file  = "location_of_creds.json"
    gcloud_zone       = "europe-west1-b"
    name_prefix       = "monaco-hot" 
    instance_count    = 1

    dynatrace_environments = {
        0 = {
            url = "https://env.live.dynatrace.com"
            paas_token = "xxx"
            api_token = "yyy"
        }
    }
    ```

    > Note: the `instance_count` variable needs to be the same as the number of `dynatrace_environments`
    > Note: the key of `dynatrace_environments` needs to be 0-based and incremental, so 0, 1, 2, 3, ...

    Check out `variables.tf` for a complete list of variables

2.  Verify the configuration by running `terraform plan`
    
    ```
    $ terraform plan
    ```

3. Apply the configuration

    ```
    $ terraform apply
    ```


### Using the environment

After provisioning, terraform will give the output of all the public ip addresses.
You can log in with ssh using `ace` as username and password.
A dashboard gets created that can be accessed via a browser on `http://dashboard.VM_IP.nip.io` which has links to jenkins and gitea