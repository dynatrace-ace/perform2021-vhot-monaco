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

1. Set the following variables required for the `create-dt-env.sh` script.

    ```bash
    NUM_USERS=2
    DT_ENV_NAME_PREFIX=ENVNAME-VHOT
    DT_CLUSTER_URL=https://env.managed-sprint.dynalabs.io
    DT_CLUSTER_TOKEN=your_cluster_api_token
    DT_TAGS=owner:test@dynatrace.com
    ```

1. Run the `create-dt-env.sh` to create the necessary number of Dynatrace monitoring environments along with their tokens:

    ```bash
    $ sh create-dt-env.sh
    ```

1. The script will create a `dt_envs.txt` file containing the environments formatted strings that can be added to the `terraform.tfvars` in the following steps.

1. Prepare Service Account and download JSON key credentials in GCP.

    ```bash
    https://cloud.google.com/iam/docs/creating-managing-service-accounts
    ```

1. Initialize terraform

    ```bash
    $ terraform init
    ```    `

1. Create a `terraform.tfvars` file inside the *terraform* folder
   It needs to contain the following as a minimum:

    ```hcl
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

1.  Verify the configuration by running `terraform plan`
    
    ```bash
    $ terraform plan
    ```

1. Apply the configuration

    ```bash
    $ terraform apply
    ```

### Using the environment

After provisioning, terraform will give the output of all the public ip addresses.
You can log in with ssh using `ace` as username and password.
A dashboard gets created that can be accessed via a browser on `http://dashboard.VM_IP.nip.io` which has links to jenkins and gitea