## Delete

### Delete Configuration
Configuration which is not needed anymore can also be deleted in an automated fashion. Upon a successful deployment, Monaco looks for a delete.yaml file located in the project's root folder and deletes all specified configurations. In delete.yaml you have to specify to be deleted configurations by `name` (not id).

Here is one example of `delete.yaml` with multiple configurations:

```yaml
delete:
  - "auto-tag/app-one"
  - "auto-tag/app-two"
  - "management-zone/app-one"    
  - "calculated-metrics-service/simplenode.staging" 
```

**Warning: If the same name is used for a new config and one defined in delete.yaml, the config will be deleted right after deployment.**

During this exercise, we will run the Monaco command line to delete a specific configuration (auto tag from exercise one).

### Prerequisites

You have successfully completed exercise one.

### Step One - create a delete.yaml file

1. Create a new `delete.yaml` file within Gitea in `perform/monaco/01_exercise_one/projects`
    ![Owner delete yaml](../../assets/images/delete_yaml.png)
2. Add the following content to `delete.yaml`
   
    ```yaml
    delete:
      - "auto-tag/Owner"
    ```

3. Commit your changes

### Step Two - Verify the target object ("owner" tagging rule) exist
1. Open the Dynatrace UI and navigate to `Settings`
2. Open `Tags` -> `Automatically applied tags`
3. Verify tagging rule `owner` exist

    ![Owner Tag](../../assets/images/Ownertagui.png)

### Step Three - Pull delete.yaml file and execute Monaco command

1. Open the Dynatrace University Terminal
2. cd into the exercise-one directory
    ```bash
    $ cd ~/perform/monaco/01_exercise_one
    ```
3. Execute the following command to pull down our changes from the remote repository.
    ```bash
    $ git pull
    ```
    Make sure delete.yaml is pulled into the current directory (for example:)

    ![Owner git pull yaml](../../assets/images/git_pull.png)

4. Make sure the `DT_API_TOKEN` env variable is set

    ```bash
    $ export DT_API_TOKEN=$(kubectl -n dynatrace get secret oneagent -o jsonpath='{.data.apiToken}' | base64 -d)
    ```

5. Run Monaco commandline

    ```bash
    $ monaco -v -e projects/environments.yaml projects/
    ```
    Monaco should execute and you should not see any errors

    ![Owner git pull yaml](../../assets/images/delete_console.png)

6. Check your Dynatrace environment make sure `Owner` tagging rule is deleted.

### ***Congratulations on completing exercise six!***
