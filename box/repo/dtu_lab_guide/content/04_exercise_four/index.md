## Variables

Exercise four builds on top of exercise two - where we used a Jenkins pipeline to manage our Dynatrace configuration using Monaco.

Envision a scenario where you have similar application configurations multiple times - either in the same or in a different Dynatrace environment. You want to uniformily configure these applications so you use the same json template. How can you handle a requirement where one of the settings of this application should be different across instances of this template, e.g. user session coverage percentage?

The goal of this exercise is to introduce variables in our json templates to manage this requirement.

During this exercise we will apply a large amount of configuration to our Dynatrace environment using a Jenkins pipeline:


### Step 1 - Explore configuration
#### Folder structure
Using Gitea, explore the contents of the `monaco/04_exercise_four` folder. It is the same as the structure of `monaco/02_exercise_two` looks like this:
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
#### Application configuration
In Gitea navigate to the **application** definitions stored within the **perform** project in `monaco/04_exercise_four/projects/perform/application`. You will find two files:
- `application.json` is the **configuration template**
- `application.yaml` defines **configuration instances**

### Step 2 - Introduce variable
In order to use variables in a Monaco configuration we must first replace it's value in the json object with `{{ VARIABLE_NAME }}`. In our example, we want to turn UEM coverage percentage, represented in the `application.json` by the field `costControlUserSessionPercentage` in a variable called `uemPercentage`.

To do so, using Gitea, find the file and edit it.

On line 4, find the field `costControlUserSessionPercentage` and see that the value is hardcoded to `10`:

```json
"costControlUserSessionPercentage": 10,
```

Turn the value of that field (`10`) into a variable:

```json
"costControlUserSessionPercentage": "{{ .uemPercentage }}",
```

**Note**: we need to surround the variable placeholders with double quotes `"`, even if it is not a string value.

**Note**: the `.` in front of `uemPercentage` is required

Commit the changes.

### Step 3 - Reference value and assign a value

Now that we have defined our variable in the json template, we can assign values for it in the yaml file that contains the instances of the template to be created. Open the `application.yaml` file and for each instance of the application add the variable and assign a value to it:

```yaml
config:
    - app-app-one: "application.json"
    - app-app-two: "application.json"
  
app-app-one:
    - name: "app-one"
    - uemPercentage: "100"

app-app-two:
    - name: "app-two"
    - uemPercentage: "50"
```

Commit the changes.

### Step 4 - Run the pipeline

In Jenkins, launch the pipeline `Exercise 4 - Update config`.

The pipeline will now update the two application configurations and will change the `costControlUserSessionPercentage` from a fixed value to a parametrized value using Monaco.

### Step 5 - View results in Dynatrace

As a last step, go to your Dynatrace environment and verify that Monaco updated the application definition.

### This concludes exercise four.
