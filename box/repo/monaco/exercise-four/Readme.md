# Monaco HOT - Exercise Four
Exercise four builds on top of Exercise two - where we used a Jenkins pipeline to manage our Dynatrace configuration using Monaco.

Envision a scenario where you have similar application configurations multiple times - either in the same or in a different Dynatrace environment. You want to uniformily configure these applications so you use the same JSON template. How can you handle a requirement where one of the settings of this application should be different across all the instances of this template - for example UEM coverage percentage.

The goal of this exercise is to introduce variables in our JSON templates to manage this requirement.

During this exercise we will apply a large amount of configuration to our Dynatrace environment using a Jenkins pipeline:


## Step 1 - Explore configuration
### Folder structure
Using gitea, explore the contents of the `monaco/project-four` folder. It is the same as the structure of `monaco/project-two` looks like this:
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
### Application configuration
Navigate, in gitea, to the **application** definitions stored within the **perform** project.

The `application.json` file or the **configuration template**:
{
    "name": "{{ .name }}",
    "realUserMonitoringEnabled": true,
    "costControlUserSessionPercentage": 10,
    "loadActionKeyPerformanceMetric": "VISUALLY_COMPLETE",
    "xhrActionKeyPerformanceMetric": "VISUALLY_COMPLETE",
    "loadActionApdexSettings": {
      "threshold": 1,
      "toleratedThreshold": 1000,
      "frustratingThreshold": 3000,
      "toleratedFallbackThreshold": 1300,
      "frustratingFallbackThreshold": 3300,
      "considerJavaScriptErrors": true
    },
    "xhrActionApdexSettings": {
      "threshold": 3,
      "toleratedThreshold": 3000,
      "frustratingThreshold": 12000,
      "toleratedFallbackThreshold": 3000,
      "frustratingFallbackThreshold": 12000,
      "considerJavaScriptErrors": true
    },
    "customActionApdexSettings": {
      "threshold": 3,
      "toleratedThreshold": 3000,
      "frustratingThreshold": 12000,
      "toleratedFallbackThreshold": 3000,
      "frustratingFallbackThreshold": 12000,
      "considerJavaScriptErrors": true
    },
    "waterfallSettings": {
      "uncompressedResourcesThreshold": 860,
      "resourcesThreshold": 100000,
      "resourceBrowserCachingThreshold": 50,
      "slowFirstPartyResourcesThreshold": 200000,
      "slowThirdPartyResourcesThreshold": 200000,
      "slowCdnResourcesThreshold": 200000,
      "speedIndexVisuallyCompleteRatioThreshold": 50
    },
    "monitoringSettings": {
      "fetchRequests": true,
      "xmlHttpRequest": true,
      "javaScriptFrameworkSupport": {
        "angular": true,
        "dojo": false,
        "extJS": false,
        "icefaces": false,
        "jQuery": false,
        "mooTools": false,
        "prototype": false,
        "activeXObject": false
      },
      "contentCapture": {
        "resourceTimingSettings": {
          "w3cResourceTimings": true,
          "nonW3cResourceTimings": false,
          "nonW3cResourceTimingsInstrumentationDelay": 50,
          "resourceTimingCaptureType": "CAPTURE_FULL_DETAILS",
          "resourceTimingsDomainLimit": 10
        },
        "javaScriptErrors": true,
        "timeoutSettings": {
          "timedActionSupport": false,
          "temporaryActionLimit": 0,
          "temporaryActionTotalTimeout": 100
        },
        "visuallyCompleteAndSpeedIndex": true
      },
      "excludeXhrRegex": "",
      "injectionMode": "JAVASCRIPT_TAG",
      "libraryFileLocation": "",
      "monitoringDataPath": "",
      "customConfigurationProperties": "",
      "serverRequestPathId": "",
      "secureCookieAttribute": false,
      "cookiePlacementDomain": "",
      "cacheControlHeaderOptimizations": true,
      "advancedJavaScriptTagSettings": {
        "syncBeaconFirefox": false,
        "syncBeaconInternetExplorer": false,
        "instrumentUnsupportedAjaxFrameworks": false,
        "specialCharactersToEscape": "",
        "maxActionNameLength": 100,
        "maxErrorsToCapture": 10,
        "additionalEventHandlers": {
          "userMouseupEventForClicks": false,
          "clickEventHandler": false,
          "mouseupEventHandler": false,
          "blurEventHandler": false,
          "changeEventHandler": false,
          "toStringMethod": false,
          "maxDomNodesToInstrument": 5000
        },
        "eventWrapperSettings": {
          "click": false,
          "mouseUp": false,
          "change": false,
          "blur": false,
          "touchStart": false,
          "touchEnd": false
        },
        "globalEventCaptureSettings": {
          "mouseUp": true,
          "mouseDown": true,
          "click": true,
          "doubleClick": true,
          "keyUp": true,
          "keyDown": true,
          "scroll": true,
          "additionalEventCapturedAsUserInput": ""
        }
      }
    },
    "userActionNamingSettings": {
      "placeholders": [],
      "loadActionNamingRules": [],
      "xhrActionNamingRules": [],
      "ignoreCase": true,
      "splitUserActionsByDomain": true
    },
    "metaDataCaptureSettings": [],
    "conversionGoals": []
  }

The `application.yaml` file or the **configuration instances**:

### Jenkins pipeline
Using gitea, open the file [jenkins/exercise-two.Jenkinsfile](../../jenkins/exercise-two.Jenkinsfile)
```
ENVS_FILE = "monaco/exercise-two/environments.yaml"

pipeline {
    agent {
        label 'monaco-runner'
    }
    stages {
        stage('Dynatrace global config - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE -p=global monaco/exercise-two/projects"
                    }
                }
			}
		}
        stage('Dynatrace global config - Deploy') {
			steps {
                container('monaco') {
                    script {
				        sh "monaco -v -e=$ENVS_FILE -p=global monaco/exercise-two/projects"
                        sh "sleep 60"
                    }
                }
			}
		}       
        stage('Dynatrace Perform project - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE -p=perform monaco/exercise-two/projects"
                    }
                }
			}
		}
        stage('Dynatrace Perform project - Deploy') {
			steps {
                container('monaco') {
                    script {
				        sh "monaco -v -e=$ENVS_FILE -p=perform monaco/exercise-two/projects"
                    }
                }
			}
		}       
    }
}
```
A few important sections are noted:
### The monaco-runner
```
agent {
    label 'monaco-runner'
}
```
```
...
container('monaco')
...
```
This section refers to the `monaco-runner`, a container that was precreated by the Dynatrace ACE services team that can be used within a CI/CD pipeline.
Within the `monaco` container, we now have the `monaco` CLI available. For more information, visit https://github.com/dynatrace-ace/monaco-runner.

Go to **Manage Jenkins** >> **Configure System** >> **Cloud configuration page** (bottom of settings page) >> **Pod Templates** >> **Pod Template monaco-runner** >> **Pod Template details...** and look at the configuration.
![](resources/pod_template.png).

By using this pod template in our Jenkins pipeline, we make the `monaco` command from within the pod available within our pipeline.

### The environments.yaml file
On the first line of the Jenkinsfile we find the following:
```
ENVS_FILE = "monaco/exercise-two/environments.yaml"
```
This file looks like this (you can verify this using Gitea):
```
perform:
  - name: "perform"
  - env-url: "{{ .Env.DT_TENANT_URL }}" 
  - env-token-name: "DT_API_TOKEN" 
```
We defined a Dynatrace environment for Monaco to handle called `perform`.
The attributes `env-url` and `env-token-name` contain the names of **environment variable** that contain the environment url and API token respectively. Note the difference in notation. Within Monaco it is possible to use environment variables anywhere, by using the format `{{ .Env.YOUR_ENV_VAR_NAME }}`. For the token, it is slightly different as this was historically always the name of an environment variable, so here you just put the format `YOUR_ENV_VAR_NAME` to load your token.

So the question is: **Where are those variables stored?**

Jenkins always passes all environment variables that are defined in its system to all the pipelines that are running. If we open **Manage Jenkins** >> **Configure System** and we scroll down a bit we see all the environment variables that are defined, including the Dynatrace Environment URL and Dynatrace API Tokens:
![](resources/jenkins_envvars.png).

Monaco, when running, will load and replace all environment variables where it can. If an environment variable is not set, it will throw a validation error.

### Dry-run vs deploy
For each project, notice there are two stages:
```
stage('Dynatrace global config - Validate') {
    steps {
        container('monaco') {
            script{
                sh "monaco -v -dry-run -e=$ENVS_FILE -p=global monaco/exercise-two/projects"
            }
        }
    }
}
stage('Dynatrace global config - Deploy') {
    steps {
        container('monaco') {
            script {
                sh "monaco -v -e=$ENVS_FILE -p=global monaco/exercise-two/projects"
                sh "sleep 60"
            }
        }
    }
}       
```

For the first stage, we add an extra argument, `-dry-run`, which will only validate the structure of our project (and dependant projects). It is similar to a `terraform plan`.

## Step 2 - Trigger pipeline
Once we are familiar with the project structure and the contents, it is time to trigger our pipeline.

Navigate to the **Jenkins Dashboard**, open the pipeline **Exercise 2 - Apply all**, and click on **Build Now**.

![](resources/jenkins_exercise-two.png)

The pipeline will now run and apply the two Monaco projects - **Global** and **Perform** - to the Dynatrace Environment.

Wait until the pipeline has finished, you will be able to see it if all stages completed succesfully:

![](resources/jenkins_exercise-two_run.png)

Click on the build number, in the screenshot above it will be **#12**, this brings you to the build details. Click on **Console Output**

![](resources/jenkins_exercise-two_rundetails.png)

In the **Console Output** you can track the progress and changes that Monaco made.

![](resources/jenkins_exercise-two_console.png)

## Step 3 - View results in Dynatrace

As a last step, go to your Dynatrace environment and verify that Monaco created all the configurations as described in the two Monaco projects.

That concludes this lab.