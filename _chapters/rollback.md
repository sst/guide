Making sure that you are able to rollback your Serverless deployments is critical to managing your own CI/CD pipeline. In this chapter we’ll look at what the right rollback strategy is for your Serverless apps.

# Rollback to previous build

To rollback to a previous build, go to your Seed app. Notice we have pushed some faulty code to `dev` stage. Let's select `dev` to see a list of historical builds in the stage.

![](/assets/best-practices/rollback-1.png)

Pick a previous build and select **Rollback**.

![](/assets/best-practices/rollback-2.png)

Notice a new build is triggered for the `dev` stage.

![](/assets/best-practices/rollback-3.png)

# Rollback infrastructure change

In our monorepo setup, our app is made up of multiple services, and some services are dependent on another. These dependencies require the services to be deployed in a specific order. We have talked about how to [Deploying services with dependency in phases]. We also need to watch out for deployment order when rolling back a change that involves dependency change.

Let’s consider a simple example with just two services, `serviceA` and `serviceB`. Say you added an SNS topic named `ATopic` in ServiceA and exported the topic’s ARN. Here is an example of ServiceA’s `serverless.yml`:
``` yaml
service: serviceA
...
resources:
  - Outputs:
        ATopicArn:
          Value:
            Ref: ATopic
          Export:
            Name: ATopicArn
```
And ServiceB imports the topic and uses it to trigger the `topicHandler` function:
``` yaml
service: serviceB
...
functions:
  topicHandler:
    handler: handler.main
    events:
      - sns:
        'Fn::ImportValue': ATopicArn
```
You commit the changes and deploy the services. Note that ServiceA had to be deployed first. This is to make sure that the export value `ATopicArn` exists, and then we deploy ServiceB.

Assume that after the services have been deployed, your Lambda functions start to error out and you have to rollback.

In this case, you need to: **rollback the services in the reverse order of the deployment**.

Meaning ServiceB needs to be rolled back first, such that the exported value `ATopicArn` is not used by other services, and then rollback ServiceA to remove the SNS topic along with the export.
