# Monaco HOT - Exercise Seven - Linking configs

In this exercise we will show how we can link multiple configurations together without having to manually figure out the IDs of the configurations.
We will reference them using Monaco config instances and let Monaco figure out the IDs, dependencies and priorities!

## Step 1 - Take a look at the project
In gitea, navigate to `monaco/exercise-seven`.
You will find a standard monaco setup:
```

```

We have an `alerting-profile` that references a `management-zone` and a `notification` that references an `alerting-profile`.
It is up to us to complete the configurations so that Monaco can create all configurations in one go.