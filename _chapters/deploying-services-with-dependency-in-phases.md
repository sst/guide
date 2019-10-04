---
layout: post
title: Deploying services with dependency in phases
description: 
date: 2019-09-29 00:00:00
comments_id: 
---

So now that we have a couple of downstream services that are referencing a resource deployed in an upstream service; let's look at how this dependency affects the way we deploy our app.

The short version is that:

- When you introduce a new dependency in your app you cannot deploy all the services concurrently.
- However, once these services have been deployed, you can do so.

#### First deployment

TODO: UPDATE LINK

If you are deploying [our sample app] for the first time, you have to:
- Deploy the `notes-api` first. This will export the value `dev-ApiGatewayRestApiId` and `dev-ApiGatewayRestApiRootResourceId`.
- Then deploy the `billing-api` next. This will export the value `NotePurchasedTopicArn-dev`.
- Then deploy the `notify-job`.

Assuming that you are deploying to the `dev` stage.

If you were to deploy `billing-api` and `notify-job` concurrently, the `notify-job` will fail with the following CloudFormation error:

```
notify-job - No export named NotePurchasedTopicArn-dev found.
```

This error is basically saying that the ARN referenced in its `serverless.yml` does not exist. This makes sense because we haven’t created it yet!

#### Subsequent deployments

Once the three services have been successfully deployed, you can deploy them all concurrently. This is because the referenced ARN has already been created.

#### Adding new dependencies

Say you add a new SNS topic in `billing-api` service and you want the `notify-job` service to subscribe to that topic. The first deployment after the change, will again fail if all the services are deployed concurrently. You need to deploy the `billing-api` service first, and then deploy the `notify-job` service.

### Managing deployment in phases

A monorepo app usually has multiple API services and multiple background services (ie. cron jobs, step functions, SNS/SQS subscribers). A common dependency pattern is that the jobs services depend on the API services. This is simply because the API services always response synchronously to user requests, and they in turn invoke the jobs to do more work.

So it's easier to visualize your services in phases. Deploy the services in each phase _concurrently_ while deploying the phases _sequentially_. With [Seed](https://seed.run), we handle this using a concept of [Deploy Phases](https://seed.run/docs/configuring-deploy-phases).

TODO: INSERT SEED DEPLOY PHASES SCREENSHOT
