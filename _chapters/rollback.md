---
layout: post
title: Rollback
description: In this chapter we look at how to rollback services in our monorepo Serverless app. If we are rolling back services with dependencies, we need to make sure to roll them back in the opposite order they were deployed in.
date: 2019-10-02 00:00:00
comments_id: 
---

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

Let’s consider a simple example with just two services, `billing-api` and `notify-job`. And `billing-api` exports an SNS topic named `note-purchased` in ServiceA and exported the topic’s ARN. Here is an example of `billing-api`’s `serverless.yml`:
``` yaml
  Outputs:
    NotePurchasedTopicArn:
      Value:
        Ref: NotePurchasedTopic
      Export:
        Name: NotePurchasedTopicArn-${self:custom.stage}
```
And the `notify-job` service imports the topic and uses it to trigger the `notify` function:
``` yaml
functions:
  notify:
    handler: notify.main
    events:
      - sns:
        'Fn::ImportValue': NotePurchasedTopicArn-${self:custom.stage}
```
Note that the `billing-api` service had to be deployed first. This is to make sure that the export value `NotePurchasedTopicArn` exists, and then we deploy the `notify-job` service.

Assume that after the services have been deployed, your Lambda functions start to error out and you have to rollback.

In this case, you need to: **rollback the services in the reverse order of the deployment**.

Meaning `notify-job` needs to be rolled back first, such that the exported value `NotePurchasedTopicArn` is not used by other services, and then rollback the `billing-api` service to remove the SNS topic along with the export.
