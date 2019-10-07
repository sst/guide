---
layout: post
title: Rollback
description: In this chapter we look at how to rollback services in our monorepo Serverless app. If we are rolling back services with dependencies, we need to make sure to roll them back in the opposite order they were deployed in.
date: 2019-10-02 00:00:00
comments_id: 
---

So we've worked on a new feature, deployed it to a feature branch, created a PR for it, merged it to master, and promoted it to production! We are almost done going over the workflow. But before we move on we want to make sure that you are able to rollback your Serverless deployments in case there is a problem. We think this is a critical aspect of your CI/CD pipeline. In this chapter we’ll look at what the right rollback strategy is for your Serverless apps.

Let's quickly look at how to do that in Seed.

### Rollback to previous build

To rollback to a previous build, go to your app in Seed. Let's suppose we've have pushed some faulty code to `dev` stage. Let's click on the `dev` stage to see a list of historical builds in the stage.

![](/assets/best-practices/rollback-1.png)

Pick a previous successful build and hit **Rollback**.

![](/assets/best-practices/rollback-2.png)

Notice a new build is triggered for the `dev` stage.

![](/assets/best-practices/rollback-3.png)

### Rollback infrastructure change

TODO: UPDATE LINK

In our monorepo setup, our app is made up of multiple services, and some services are dependent on each other. These dependencies require the services to be deployed in a specific order. Previously, we talked about how to [deploy services with dependencies]. We also need to watch out for the deployment order when rolling back a change that involves a dependency change.

Let’s consider a simple example with just two services, `billing-api` and `notify-job`. Where `billing-api` exports an SNS topic named `note-purchased`. Here is an example of `billing-api`’s `serverless.yml`:


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

Note that the `billing-api` service had to be deployed first. This is to make sure that the export value `NotePurchasedTopicArn` is created. Then we can deploy the `notify-job` service.

Assume that after the services have been deployed, you push a faulty commit and you have to rollback.

In this case, you need to: **rollback the services in the reverse order of the deployment**.

Meaning `notify-job` needs to be rolled back first, such that the exported value `NotePurchasedTopicArn` is not used by other services, and then rollback the `billing-api` service to remove the SNS topic along with the export.
