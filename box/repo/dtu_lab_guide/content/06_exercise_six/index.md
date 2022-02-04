## Ex 6: Delete configuration
In this exercise, we'll use Monaco to delete a specific configuration.

Configurations which aren't needed anymore can also be deleted in an automated fashion. Upon a successful deployment, Monaco looks for a delete file located in the project's root folder and deletes all specified configurations. In this file named `delete.yaml`, you must specify configurations you like to delete by `name` (not ID).

Here's one example of `delete.yaml` with multiple configurations:

```yaml
delete:
  - "auto-tag/app-one"
  - "auto-tag/app-two"
  - "management-zone/app-one"    
  - "calculated-metrics-service/simplenode.staging" 
```
### Step 1 - Verify existence of target object
Since we'll be deleting the auto tagging rule created in exercise one, let's make sure the tag still exists. 

1. Open the Dynatrace web UI and navigate to `Manage` > `Settings`

2. Open `Tags` > `Automatically applied tags`

3. Confirm that tag `Owner` still exist

    ![Owner tag](../../assets/images/05_owner_tag_ui.png)
    
### Step 2 - Prepare the delete file
1. In Gitea, copy the contents of file 
`perform/monaco/01_exercise_one/environments.yaml` 
and paste it into 
`perform/monaco/06_exercise_six/environments.yaml` 

    > **Tip:** Both files should be identical

2. Commit the changes

3. Still in Gitea, edit file `perform/monaco/06_exercise_six/delete.yaml` to make it look like the snippet below
   
    ```yaml
    delete:
      - "auto-tag/Owner"
    ```

4. Commit the changes

### Step 3 - Pull changes and run Monaco
1. Open the SSH client that's connected to your VM and navigate into the directory of this exercise

    ```bash
    cd ~/perform/monaco/06_exercise_six
    ```

2. Execute the following command to pull down changes made in Gitea

    ```bash
    git pull
    ```

    Confirm that both `environments.yaml` and `delete.yaml` are pulled into the current directory

    ```bash
    From http://gitea.***.nip.io/perform/perform
    2ce6288..0e6ff6e  master     -> origin/master
    Updating 2ce6288..0e6ff6e
    Fast-forward
    monaco/06_exercise_six/delete.yaml       | 3 ++-
    monaco/06_exercise_six/environments.yaml | 5 ++++-
    2 files changed, 6 insertions(+), 2 deletions(-)
    ```

3. Verify that the environment variable `DT_API_TOKEN` still exists

    ```bash
    echo $DT_API_TOKEN
    ```
    
    If not, recreate it from the Kubernetes secret

    ```bash
    export DT_API_TOKEN=$(kubectl -n dynatrace get secret oneagent -o jsonpath='{.data.apiToken}' | base64 -d)
    ```

4. Run Monaco

    ```bash
    monaco -v -e environments.yaml
    ```
    Monaco should execute and you shouldn't see any errors

    ```bash
    2022-02-04 12:04:10 DEBUG request log not activated
    2022-02-04 12:04:10 DEBUG response log not activated
    2022-02-04 12:04:10 INFO  Dynatrace Monitoring as Code v1.6.0
    2022-02-04 12:04:10 DEBUG Reading projects...
    2022-02-04 12:04:10 DEBUG Sorting projects...
    2022-02-04 12:04:10 INFO  Executing projects in this order:
    2022-02-04 12:04:10 INFO  Processing environment perform...
    2022-02-04 12:04:10 INFO  Deployment summary:
    2022-02-04 12:04:10 INFO  Deployment finished without errors
    2022-02-04 12:04:10 INFO  Deleting 1 configs for environment perform...
    2022-02-04 12:04:10 DEBUG 	Deleting config Owner (auto-tag)
    ```

5. Confirm in your Dynatrace tenant that the `Owner` tag doesn't exist anymore

>**Note:** If a name is used for a new configuration and the same name is defined in `delete.yaml`, the configuration will be created by Monaco and then deleted right after the deployment.
>
>For example, if we placed our `delete.yaml` file in folder `perform/monaco/01_exercise_one/projects` and ran Monaco there, the end result will be the same as this exercise. However, you'll see in the Monaco output that the tag was first (re-)created and then deleted!

#### Congratulations on completing Exercise 6!
