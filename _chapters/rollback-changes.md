---
layout: post
title: Rollback Changes
description: In this chapter we look at how to rollback services in our monorepo Serverless app. If we are rolling back services with dependencies, we need to make sure to roll them back in the opposite order they were deployed in.
date: 2019-10-02 00:00:00
comments_id: rollback-changes/1331
---

So we've worked on a new feature, deployed it to a feature branch, created a PR for it, merged it to master, and promoted it to production! We are almost done going over the workflow. But before we move on we want to make sure that you are able to rollback your Serverless deployments in case there is a problem. We think this is a critical aspect of your CI/CD pipeline. In this chapter we’ll look at what the right rollback strategy is for your Serverless apps.

Let's quickly look at how to do that in Seed.

### Rollback to previous build

To rollback to a previous build, go to your app in Seed. Let's suppose we've pushed some faulty code to `prod` stage. Click on the `prod` stage to see a list of historical builds in the stage.

![Select prod stage in Seed](/assets/best-practices/rollback/select-prod-stage-in-seed.png)

Pick an older successful build and hit **Rollback**.

![Select Rollback in prod stage](/assets/best-practices/rollback/select-rollback-in-prod-stage.png)

Notice a new build is triggered for the `prod` stage.

![Show rolling back in prod stage](/assets/best-practices/rollback/show-rolling-back-in-prod-stage.png)

### Rollback infrastructure change

In our monorepo setup, our app is made up of multiple services, and some services are dependent on each other. These dependencies require the services to be deployed in a specific order. Previously, we talked about how to [deploy services with dependencies]({% link _chapters/deploy-a-serverless-app-with-dependencies.md %}). We also need to watch out for the deployment order when rolling back a change.

Let’s consider a simple example with just two services, `billing-api` and `notify-job`. Where `billing-api` exports an SNS topic named `note-purchased`. Here is an example of `billing-api`’s `serverless.yml`:


``` yaml
Outputs:
  NotePurchasedTopicArn:
    Value:
      Ref: NotePurchasedTopic
    Export:
      Name: ExtNotePurchasedTopicArn-${self:custom.stage}
```

And the `notify-job` service imports the topic and uses it to trigger the `notify` function:

``` yaml
functions:
  notify:
    handler: notify.main
    events:
      - sns:
        'Fn::ImportValue': ExtNotePurchasedTopicArn-${self:custom.stage}
```

Note that the `billing-api` service had to be deployed first. This is to make sure that the export value `ExtNotePurchasedTopicArn` has first been created. Then we can deploy the `notify-job` service.

Assume that after the services have been deployed, you push a faulty commit and you have to rollback.

In this case, you need to: **rollback the services in the reverse order of the deployment**.

Meaning `notify-job` needs to be rolled back first, such that the exported value `ExtNotePurchasedTopicArn` is not used by other services, and then rollback the `billing-api` service to remove the SNS topic along with the export.

Next we are going to look at an optimization that you can make to speed up your builds.
