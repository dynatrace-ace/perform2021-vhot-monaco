## Lab environment

### Overview
Each participant has a dedicated lab environment that includes: 
* Dynatrace environment (a.k.a. Dynatrace tenant)
* Kubernetes cluster
    * Dashboard (links and app status)
    * Jenkins (automation server)
    * Gitea (Git server)
    * Applications (app-one, app-two, app-three)
    * Container registry
    * OneAgent (deployed by OneAgent Operator)
    * Nginx (reverse proxy)
* Synthetic ActiveGate (private location)
* Monaco (command line interface tool)

![Lab environment](../../assets/images/00_lab_environment.png)

### Connect
1. Log in on `Dynatrace University`
    https://university.dynatrace.com

2. On your university dashboard, you'll see an event named `GitOps for Observability with Monitoring as Code`. Go ahead and open up the event.

3. Select the `Environments` tab. Click on `Open terminal` and execute the command below to ensure Monaco is properly installed on your VM.

    ```
    monaco
    ```

    > **Note:** Dynatrace University provides a browser-based SSH client (recommended). If you prefer, you can use your own SSH client with the VM credentials shown on the `Environments` tab.

    The expected output for this command will be the Monaco help page that explains usage and command options.

    ```bash
    You are currently using the old CLI structure which will be used by
    default until monaco version 2.0.0

    Check out the beta of the new CLI by adding the environment variable
    "NEW_CLI".

    NAME:
    monaco - Automates the deployment of Dynatrace Monitoring Configuration to one or multiple Dynatrace environments.

    USAGE:
    monaco [global options] command [command options] [working directory]

    VERSION:
    1.6.0

    DESCRIPTION:
    Tool used to deploy dynatrace configurations via the cli

    Examples:
        Deploy a specific project inside a root config folder:
        monaco -p='project-folder' -e='environments.yaml' projects-root-folder

        Deploy a specific project to a specific tenant:
        monaco --environments environments.yaml --specific-environment dev --project myProject

    COMMANDS:
    help, h  Shows a list of commands or help for one command

    GLOBAL OPTIONS:
    --verbose, -v                             (default: false)
    --environments value, -e value            Yaml file containing environments to deploy to
    --specific-environment value, --se value  Specific environment (from list) to deploy to (default: none)
    --project value, -p value                 Project configuration to deploy (also deploys any dependent configurations) (default: none)
    --dry-run, -d                             Switches to just validation instead of actual deployment (default: false)
    --continue-on-error, -c                   Proceed deployment even if config upload fails (default: false)
    --help, -h                                show help (default: false)
    --version                                 print the version (default: false)
    2022-02-03 11:40:27 ERROR Required flag "environments" not set
   ```

4. From the `Environments` tab, use the `View environment` button to open up your Dynatrace environment in a new window and sign in with the provided credentials.

5. Copy your VM's public IP address from the `Environments` tab. Add a new tab to the new window of the previous step and navigate to the URL below, replacing `<VM_IP>` with your VM's IP address: 

    > `http://dashboard.<VM_IP>.nip.io`

    This is how the dashboard page should look like: 

    ![Dashboard page](../../assets/images/00_dashboard_page.png)

6. Via the links on the dashboard page, open up **Gitea** and **Jenkins** in new tabs and log in with the credentials shown on the dashboard page.

> **Note:** All further lab instructions will be provided in this repo itself. The Monaco documentation can be found on [GitHub](https://github.com/dynatrace-oss/dynatrace-monitoring-as-code).

### We're now ready to kick off the lab!
