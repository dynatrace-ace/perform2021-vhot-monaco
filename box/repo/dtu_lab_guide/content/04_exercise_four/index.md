## Ex 4: Configuration variables
This exercise builds on top of exercise two—where we used a Jenkins pipeline and Monaco to manage our Dynatrace configuration.

Envision a scenario where you have similar application configurations, either in the same or in a different Dynatrace environment. You want to uniformly configure these applications so you use the same JSON template. How can you handle a requirement where one of the settings (e.g. user session coverage percentage) must be different across instances of this template?

The goal of this exercise is to introduce variables in our JSON templates to manage this requirement.

### Step 1 - Explore configuration
#### Folder structure
1. Using Gitea, explore the contents of the `perform/monaco/04_exercise_four` folder. It's the same structure as that of `perform/monaco/02_exercise_two` and looks like this:

    ```
    │── environments.yaml
    └── projects
        │── global
        │   │── auto─tag
        │   │   │── auto─tag.json
        │   │   └── auto─tag.yaml
        │   │── request─attributes
        │   │   │── request─attribute.json
        │   │   └── request─attribute.yaml
        │   └── synthetic─location
        │       │── private─synthetic.json
        │       └── synthetic─location.yaml
        └── perform
            │── app─detection─rule
            │   │── rule.json
            │   └── rules.yaml
            │── application
            │   │── application.json
            │   └── application.yaml
            │── auto─tag
            │   │── tagging.json
            │   └── tagging.yaml
            │── calculated─metrics─service
            │   │── csm.json
            │   └── csm.yaml
            │── dashboard
            │   │── dashboard.json
            │   └── dashboard.yaml
            │── management─zone
            │   │── management─zone.json
            │   └── zone.yaml
            └── synthetic─monitor
                │── health─check─monitor.json
                └── synthetic─monitors.yaml
    ```
#### Application configuration
2. In Gitea navigate to the application definitions stored in `perform/monaco/04_exercise_four/projects/perform/application` 

    You will find two files:
    * `application.json` is the **configuration template**
    * `application.yaml` defines **configuration instances**

### Step 2 - Introduce variables
In order to use variables in a Monaco configuration, we must replace hardcoded values in JSON objects with variables using the format:

```
{{ .VARIABLE_NAME }}
```

In our example, we want to turn RUM coverage percentage, represented in the `application.json` file by the field `costControlUserSessionPercentage` in a variable called `rumPercentage`.

1. To do so, in Gitea open file `application.json`

2. On line 4, find the field `costControlUserSessionPercentage` and notice that the value is hardcoded as `10`:

    ```json
    "costControlUserSessionPercentage": 10,
    ```

3. Turn the value of that field `10` into a variable:

    ```json
    "costControlUserSessionPercentage": "{{ .rumPercentage }}",
    ```

    > **Note:** Even though the variable placeholder doesn't represent a string value, it must still be surrounded with double quotes `"`
    >
    >The dot `.` in front of `rumPercentage` is also required as it's part of the format.

4. Commit the changes

### Step 3 - Reference value and assign a value
Now that we have defined a variable in the JSON template, we can assign values to it in the YAML file that contains the instances of the template to be created.

1. In Gitea, open the `application.yaml` file and for each application instance add the variable and assign a value to it like shown in the snippet below:

    ```yaml
    config:
        - app-app-one: "application.json"
        - app-app-two: "application.json"
    
    app-app-one:
        - name: "app-one"
        - rumPercentage: "100"

    app-app-two:
        - name: "app-two"
        - rumPercentage: "50"
    ```

2. Commit the changes

### Step 4 - Run the pipeline
1. In Jenkins, launch the pipeline `Exercise 4 - Update config`

    ![Jenkins pipeline](../../assets/images/04_jenkins_pipeline.png)

    The pipeline will now update the two application configurations and will change the `costControlUserSessionPercentage` from a fixed value to a parametrized value using Monaco.
### Step 5 - View results in Dynatrace
1. As a last step, go to your Dynatrace environment and verify that Monaco updated the application settings.

    ![RUM coverage app-one](../../assets/images/04_rum_app1.png)

    ![RUM coverage app-two](../../assets/images/04_rum_app2.png)

### This concludes Exercise 4!
