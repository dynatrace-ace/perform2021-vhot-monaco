## Ex 3: Download all configuration

In this exercise, we'll see how Monaco can be used to download an existing environment's configuration. This is particularly handy when there are numerous existing custom configurations. You can download your configuration and push it into a repository, or use it as a starting point for managed configuration changes through Monaco.

### Step 1 - Create an environments file
The first step, similar to what we did in exercise one, is to create an `environments.yaml` file.

1. In Gitea, copy the contents of file 
`perform/monaco/01_exercise_one/environments.yaml` 
and paste it into 
`perform/monaco/03_exercise_three/environments.yaml` 

   > **Tip:** Both files should be identical

2. Commit the changes

### Step 2 - Download configuration
1. Open up the SSH client that is connected to your VM and navigate into the `perform` folder in your home directory

   ```bash
   cd ~/perform
   ```

2. Update the locally stored repo with all the changes made in Gitea

   ```bash
   git pull
   ```

3. Verify that the environment variable `DT_API_TOKEN` still exists

   ```bash
   echo $DT_API_TOKEN
   ```

   If not, recreate it from the Kubernetes secret

   ```bash
   export DT_API_TOKEN=$(kubectl -n dynatrace get secret oneagent -o jsonpath='{.data.apiToken}' | base64 -d)
   ```

4. Navigate into this exercise's folder

   ```bash
   cd ~/perform/monaco/03_exercise_three
   ```

5. We'll use the new experimental CLI which allows us to download the Dynatrace configurations directly with Monaco. We can activate it by supplying the environment variable `NEW_CLI=true` to the `monaco` command.

   Execute the following command to get an overview of the options:

   ```bash
   NEW_CLI=true monaco
   ```

   This will result in:

   ```bash
   You are using the new CLI structure which is currently in Beta.

   Please provide feedback here:
   https://github.com/dynatrace-oss/dynatrace-monitoring-as-code/issues/45.

   We plan to make this CLI GA in version 2.0.0

   NAME:
      monaco - Automates the deployment of Dynatrace Monitoring Configuration to one or multiple Dynatrace environments.

   USAGE:
      monaco [global options] command [command options] [arguments...]

   VERSION:
      1.6.0

   DESCRIPTION:
      Tool used to deploy dynatrace configurations via the cli

      Examples:
      Deploy a specific project inside a root config folder:
         monaco deploy -p='project-folder' -e='environments.yaml' projects-root-folder

      Deploy a specific project to a specific tenant:
         monaco deploy --environments environments.yaml --specific-environment dev --project myProject

   COMMANDS:
      deploy    deploys the given environment
      download  download the given environment
      help, h   Shows a list of commands or help for one command

   GLOBAL OPTIONS:
      --help, -h  show help (default: false)
      --version   print the version (default: false)
   ```

6. We now have access to a new option to download the configuration, let's try it out with the command below:

   ```bash
   NEW_CLI=true monaco download -e=environments.yaml
   ```

   Monaco will now download the config:
   ```bash
   You are using the new CLI structure which is currently in Beta.

   Please provide feedback here:
   https://github.com/dynatrace-oss/dynatrace-monitoring-as-code/issues/45.

   We plan to make this CLI GA in version 2.0.0

   2022-02-04 11:30:48 INFO  Dynatrace Monitoring as Code v1.6.0
   2022-02-04 11:30:48 INFO  Creating base project name perform
   2022-02-04 11:30:48 INFO   --- GETTING CONFIGS for failure-detection-parametersets
   2022-02-04 11:30:48 INFO  No elements for API failure-detection-parametersets
   2022-02-04 11:30:48 INFO   --- GETTING CONFIGS for synthetic-monitor
   2022-02-04 11:30:48 INFO   --- GETTING CONFIGS for request-attributes
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for credential-vault
   2022-02-04 11:30:49 INFO  No elements for API credential-vault
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for failure-detection-rules
   2022-02-04 11:30:49 INFO  No elements for API failure-detection-rules
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for conditional-naming-host
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for conditional-naming-processgroup
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for application
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for request-naming-service
   2022-02-04 11:30:49 INFO  No elements for API request-naming-service
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for custom-service-dotnet
   2022-02-04 11:30:49 INFO  No elements for API custom-service-dotnet
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for kubernetes-credentials
   2022-02-04 11:30:49 INFO  No elements for API kubernetes-credentials
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for custom-service-go
   2022-02-04 11:30:49 INFO  No elements for API custom-service-go
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for conditional-naming-service
   2022-02-04 11:30:49 INFO  No elements for API conditional-naming-service
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for calculated-metrics-service
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for notification
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for azure-credentials
   2022-02-04 11:30:49 INFO  No elements for API azure-credentials
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for app-detection-rule
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for slo
   2022-02-04 11:30:49 INFO  No elements for API slo
   2022-02-04 11:30:49 INFO   --- GETTING CONFIGS for dashboard
   2022-02-04 11:30:50 INFO   --- GETTING CONFIGS for synthetic-location
   2022-02-04 11:30:50 INFO   --- GETTING CONFIGS for application-web
   2022-02-04 11:30:50 INFO   --- GETTING CONFIGS for alerting-profile
   2022-02-04 11:30:50 INFO   --- GETTING CONFIGS for custom-service-php
   2022-02-04 11:30:50 INFO  No elements for API custom-service-php
   2022-02-04 11:30:50 INFO   --- GETTING CONFIGS for maintenance-window
   2022-02-04 11:30:50 INFO   --- GETTING CONFIGS for management-zone
   2022-02-04 11:30:51 INFO   --- GETTING CONFIGS for aws-credentials
   2022-02-04 11:30:51 INFO  No elements for API aws-credentials
   2022-02-04 11:30:51 INFO   --- GETTING CONFIGS for auto-tag
   2022-02-04 11:30:51 INFO   --- GETTING CONFIGS for calculated-metrics-log
   2022-02-04 11:30:51 INFO  No elements for API calculated-metrics-log
   2022-02-04 11:30:51 INFO   --- GETTING CONFIGS for anomaly-detection-metrics
   2022-02-04 11:30:51 INFO   --- GETTING CONFIGS for extension
   2022-02-04 11:30:52 INFO   --- GETTING CONFIGS for custom-service-java
   2022-02-04 11:30:52 INFO  No elements for API custom-service-java
   2022-02-04 11:30:52 INFO   --- GETTING CONFIGS for custom-service-nodejs
   2022-02-04 11:30:52 INFO  No elements for API custom-service-nodejs
   2022-02-04 11:30:52 INFO   --- GETTING CONFIGS for application-mobile
   2022-02-04 11:30:52 INFO  END downloading info perform
   ```

7. We can now push this content back to our git repository:

   ```bash
   git add .
   git commit -m "downloaded config snapshot"
   git push
   ```

   > Tip: If you get prompted for your Gitea credentials, remember that you can find them on your dashboard page.

8. Go to Gitea and inspect the newly uploaded Dynatrace config in `perform/monaco/03_exercise_three/perform`


   ![Downloaded configuration](../../assets/images/03_downloaded_config.png)

### This concludes Exercise 3, GitOps is yet another step closer!
