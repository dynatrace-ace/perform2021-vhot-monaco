## Apply all
During this exercise we will apply a large amount of configuration to our Dynatrace environment using a Jenkins pipeline:

![](../../assets/images/jenkins_pipeline.png)

The pipeline is divided into two projects:

1. A **Global** project that contains cluster wide configurations:  
   
    - Auto tagging rules
    - Request attributes
    - Synthetic locations
    
2. A **Perform** project that contains the configuration specifically for our project:
   
    - Application definition
    - Application detection rules
    - Auto tagging rules
    - Calculated services metrics
    - Dashboards
    - Management zones
    - Synthetic monitors

### Step 1 - Explore configuration
#### Folder structure
Using gitea, explore the contents of the `monaco/02_exercise_two` folder. It looks like this:
```
|-- environments.yaml
`-- projects
    |-- global
    |   |-- auto-tag
    |   |   |-- auto-tag.json
    |   |   `-- auto-tag.yaml
    |   |-- request-attributes
    |   |   |-- request-attribute.json
    |   |   `-- request-attribute.yaml
    |   `-- synthetic-location
    |       |-- private-synthetic.json
    |       `-- synthetic-location.yaml
    `-- perform
        |-- app-detection-rule
        |   |-- rule.json
        |   `-- rules.yaml
        |-- application
        |   |-- application.json
        |   `-- application.yaml
        |-- auto-tag
        |   |-- tagging.json
        |   `-- tagging.yaml
        |-- calculated-metrics-service
        |   |-- csm.json
        |   `-- csm.yaml
        |-- dashboard
        |   |-- dashboard.json
        |   `-- dashboard.yaml
        |-- management-zone
        |   |-- management-zone.json
        |   `-- zone.yaml
        `-- synthetic-monitor
            |-- health-check-monitor.json
            `-- synthetic-monitors.yaml
```

#### Jenkins pipeline
In Gitea, open the file [jenkins/exercise-two.Jenkinsfile](../../jenkins/exercise-two.Jenkinsfile)

```groovy
ENVS_FILE = "monaco/02_exercise_two/environments.yaml"

pipeline {
    agent {
        label 'monaco-runner'
    }
    stages {
        stage('Dynatrace global config - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE -p=global monaco/02_exercise_two/projects"
                    }
                }
			}
		}
        stage('Dynatrace global config - Deploy') {
			steps {
                container('monaco') {
                    script {
				        sh "monaco -v -e=$ENVS_FILE -p=global monaco/02_exercise_two/projects"
                        sh "sleep 60"
                    }
                }
			}
		}       
        stage('Dynatrace Perform project - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE -p=perform monaco/02_exercise_two/projects"
                    }
                }
			}
		}
        stage('Dynatrace Perform project - Deploy') {
			steps {
                container('monaco') {
                    script {
				        sh "monaco -v -e=$ENVS_FILE -p=perform monaco/02_exercise_two/projects"
                    }
                }
			}
		}       
    }
}
```
A few important sections are noted:
#### The monaco-runner
```groovy
agent {
    label 'monaco-runner'
}
```
```groovy
...
container('monaco')
...
```
This section refers to the `monaco-runner`, a container that was provided by the Dynatrace ACE services team that can be used within a CI/CD pipeline.

Within the `monaco` container, we now have the `monaco` CLI available. For more information, visit https://github.com/dynatrace-ace/monaco-runner.

In Jenkins go to **Manage Jenkins** > **Configure System** > **Cloud configuration page** (bottom of settings page) > **Pod Templates** > **Pod Template monaco-runner** > **Pod Template details...** and look at the configuration.

![](../../assets/images/pod_template.png)

By using this pod template in our Jenkins pipeline, we make the pod's `monaco` command available within our pipeline.

#### The environments.yaml file
On the first line of the Jenkinsfile we find the following:
```
ENVS_FILE = "monaco/02_exercise_two/environments.yaml"
```
This file looks like this (you can verify this in Gitea):
```yaml
perform:
  - name: "perform"
  - env-url: "{{ .Env.DT_TENANT_URL }}" 
  - env-token-name: "DT_API_TOKEN" 
```
We defined a Dynatrace environment for Monaco called `perform`.

The attributes `env-url` and `env-token-name` contain the names of environment variables that contain the environment url and API token respectively. Note the difference in notation. Within Monaco it is possible to use environment variables anywhere, by using the format `{{ .Env.YOUR_ENV_VAR_NAME }}`. For the token, it is slightly different as this was historically always the name of an environment variable, so here you just put the format `YOUR_ENV_VAR_NAME` to load your token.

So the question is: **Where are those variables stored?**

Jenkins always passes all environment variables that are defined in its system to all the pipelines that are running. If we open **Manage Jenkins** > **Configure System** and we scroll down a bit we see all the environment variables that are defined, including the Dynatrace Environment URL and Dynatrace API Tokens:
![](../../assets/images/jenkins_envvars.png)

Monaco, when running, will load and replace all environment variables where it can. If an environment variable is not set, it will throw a validation error.

#### Dry-run vs deploy
For each project, notice there are two stages:
```groovy
stage('Dynatrace global config - Validate') {
    steps {
        container('monaco') {
            script{
                sh "monaco -v -dry-run -e=$ENVS_FILE -p=global monaco/02_exercise_two/projects"
            }
        }
    }
}
stage('Dynatrace global config - Deploy') {
    steps {
        container('monaco') {
            script {
                sh "monaco -v -e=$ENVS_FILE -p=global monaco/02_exercise_two/projects"
                sh "sleep 60"
            }
        }
    }
}       
```

For the first stage, we add an extra argument, `-dry-run`, which will only validate the structure of our project (and dependant projects). It is similar to a `terraform plan`.

### Step 2 - Trigger pipeline
Once we are familiar with the project structure and the contents, it is time to trigger our pipeline.

Navigate to the **Jenkins Dashboard**, open the pipeline **Exercise 2 - Apply all**, and click on **Build Now**.

![](../../assets/images/jenkins_exercise-two.png)

The pipeline will now run and apply the two Monaco projects - **Global** and **Perform** - to the Dynatrace Environment.

Wait until the pipeline has finished, you will be able to see it if all stages completed succesfully:

![](../../assets/images/jenkins_exercise-two_run.png)

Click on the build number, in the screenshot above it will be **#12**, this brings you to the build details. Click on **Console Output**

![](../../assets/images/jenkins_exercise-two_rundetails.png)

In the **Console Output** you can track the progress and changes that Monaco made.

![](../../assets/images/jenkins_exercise-two_console.png)

### Step 3 - View results in Dynatrace

As a last step, go to your Dynatrace environment and verify that Monaco created all the configurations as described in the two Monaco projects.

### Step 4 - Change configuration and re-apply

Take one of the configuration items that were created and make a change in the json file (apart from the name!). You could for example change case sensitivity for a tagging rule in `monaco/02_exercise_two/projects/perform/auto-tag/tagging.json` but feel free to experiment yourself:

![](../../assets/images/gitea_exercise-two_tagging-rule-change.png)

Re-run the pipeline and see the changes taking effect in Dynatrace.

### This concludes lab two.