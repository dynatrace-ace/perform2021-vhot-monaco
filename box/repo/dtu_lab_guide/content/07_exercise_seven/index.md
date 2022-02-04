# Linking configurations

In this exercise, we'll see how we can link multiple configurations without having to figure out the IDs of those linked configurations. Instead, we'll reference them using Monaco configuration instances and let Monaco figure out the actual IDs, dependencies and priorities!

## Step 1 - Take a look at the project
In Gitea, navigate to `perform/monaco/07_exercise_seven`

You will find a standard Monaco setup:

```bash
├── environments.yaml
└── projects
    └── perform
        ├── alerting-profile
        │   ├── profile.json
        │   └── profile.yaml
        ├── management-zone
        │   ├── management-zone.json
        │   └── zone.yaml
        └── notification
            ├── notification.json
            └── notification.yaml
```

We have the following configurations that are dependent on each other:
`notification` > `alerting-profile` > `management-zone`

It's up to us to link these configurations so that Monaco can create all of them in one go.

## Step 2 - Link the alerting profile to the management zone
1. In Gitea, open `perform/monaco/07_exercise_seven/projects/perform/management-zone/zone.yaml` 

    ```yaml
    config:
        - management-zone-app-one: "management-zone.json"
        - management-zone-app-two: "management-zone.json"

    management-zone-app-one:
        - environment: "app-one"
        - name: "app-one"

    management-zone-app-two:
        - environment: "app-two"
        - name: "app-two"
    ```

    We can see that there are two named configurations, called `management-zone-app-one` and `management-zone-app-two`. We'll use those references in our `alerting-profile`.

2. Open `perform/monaco/07_exercise_seven/projects/alerting-profile/profile.json`. 

    At the bottom, it contains two variables that point to the management-zone IDs.

    ```json
    "managementZoneId": "{{.mzId}}",
    "mzId": "{{.mzId}}",
    "eventTypeFilters": []
    ```

    No changes are needed in this file.

3. In `perform/monaco/07_exercise_seven/projects/alerting-profile/profile.yaml`, definitions of these variables have been created.

    ```yaml
    config:
        - alerting-profile-app-one: "profile.json"
        - alerting-profile-app-two: "profile.json"

    alerting-profile-app-one:
        - name: "profile-app-one"
        - mzId: ""

    alerting-profile-app-two:
        - name: "profile-app-one"
        - mzId: ""
    ```

    For the two `mzId` fields, we can now reference the management zones using Monaco references instead of IDs. The structure of the contents is as follows:

    ```
    /[PROJECT]/[CONFIG_TYPE]/[CONFIG_INSTANCE_NAME].[id|name]
    ```

    Where the fields mean the following:
    * `PROJECT`: the name of the Monaco project, for us that would be `perform`
    * `CONFIG_TYPE`: the type of configuration you want to reference, for us that would be `management-zone`
    * `CONFIG_INSTANCE_NAME`: the name of the configuration instance (**NOT the name of the configuration as it is known in Dynatrace**), for us that would be `management-zone-app-one`
    * `id|name`: which field of that configuration (as it's known in Dynatrace) you want to use, for us that would be `id`.

4. With the information above, we can now edit `perform/monaco/07_exercise_seven/projects/perform/alerting-profile/profile.yaml` to make it look like the snippet below

    ```yaml
    config:
        - alerting-profile-app-one: "profile.json"
        - alerting-profile-app-two: "profile.json"

    alerting-profile-app-one:
        - name: "profile-app-one"
        - mzId: "/perform/management-zone/management-zone-app-one.id"

    alerting-profile-app-two:
        - name: "profile-app-two"
        - mzId: "/perform/management-zone/management-zone-app-two.id"
    ```

5. Commit the changes

## Step 3 - Link the notification to the alerting profile
1. As in Step 2, go ahead and link `notification` to `alerting-profile`

## Step 4 - Trigger the pipeline
1. In Jenkins, trigger the pipeline

    `Exercise 7 - Linking configuration`

## Step 5 - View results in Dynatrace
1. Confirm in Dynatrace, that you do indeed have all the configurations and that they are correctly linked to each other in this way: 

    `notification` > `alerting-profile` > `management-zone`

## This concludes the Exercise 7 and the lab!
