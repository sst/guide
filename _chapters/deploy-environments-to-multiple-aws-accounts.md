---
layout: post
title: Deploy environments to multiple AWS accounts
description: 
date: 2019-09-30 00:00:00
comments_id: 
---

Now that you have a couple of AWS accounts created and your resources have been parameterized, let's look at how to deploy them. In this chapter, we'll deploy the `notes-api` service in our `notes-api` app to 3 environments: `featureX`, `dev`, and `prod`. The first two environments will be deployed into our `Development` AWS account and the `prod` environment will be deployed into our `Production` AWS account.

**Note that **, in reality you should never deploy to production environment from your local machine. You want this to go through your CI/CD pipeline instead. But for the purpose of this chapter, we'll do it anyways.

### Configure AWS Profiles

Follow [setup up IAM users]({% link _chapters/create-an-iam-user.md %}) chapter to create an IAM user in your `Development` account. And take a note of the **Access key ID** and **Secret access key** for the user.

Setup the credentials in your local machine using the AWS CLI:

``` bash
$ aws configure --profile default
```

This sets the default IAM credentials to those of the Development account. Meaning when you run `sls deploy`, a service will get deployed into the Development account.

Repeat the step to create an IAM user in your `Production` account. And take a note of the credentials. We will not add the IAM credentials for the Production account on our local machine. This is because we do not want us to be able to deploy code to the Production environment EVER from our local machine.

Production deployment should always go through our CI/CD pipeline.

### Configure environments on Seed

Serverless Framework has a concept of stages. They are synonymous with environments. Recall that, in the previous chapter we used this stage name to parameterize our resource names. 

Add the resource repo on Seed with **dev** and **prod** stages.
[screenshots]

Add the 3 services.
[screenshots]

Setup deploy phase
[screenshots]

You can configure this by heading to the app settings and hitting **Manage Deploy Phases**.

![Hit Manage Deploy Phases screenshot](/assets/mono-repo/hit-manage-deploy-phases.png)

Here you'll notice that by default all the services are deployed concurrently.

![Default Deploy Phase screenshot](/assets/mono-repo/default-deploy-phase.png)

Note that, you'll need to add your services first. To do this, head over to the app **Settings** and hit **Add a Service**.

![Click Add Service screenshot](/assets/mono-repo/click-add-service.png)

We can configure our service dependencies by adding the necessary deploy phases and moving the services around.

![Edit Deploy Phase screenshot](/assets/mono-repo/edit-deploy-phase.png)

And when you deploy your app, the deployments are carried out according to the deploy phases specified.

![Deploying with Deploy Phase screenshot](/assets/mono-repo/deploying-with-deploy-phase.png)

Deploy to **dev**.
[screenshots]

Deploy to **prod**.
[screenshots]


Add the api repo on Seed with **dev** annd **prod** stages.
[screenshots]

Add the 3 services.
[screenshots]

You can configure this by heading to the app settings and hitting **Manage Deploy Phases**.

![Hit Manage Deploy Phases screenshot](/assets/mono-repo/hit-manage-deploy-phases.png)

We can configure our service dependencies by adding the necessary deploy phases and moving the services around.

![Edit Deploy Phase screenshot](/assets/mono-repo/edit-deploy-phase.png)

And when you deploy your app, the deployments are carried out according to the deploy phases specified.

![Deploying with Deploy Phase screenshot](/assets/mono-repo/deploying-with-deploy-phase.png)
Setup deploy phase
[screenshots]

Deploy to **dev**.
[screenshots]

Deploy to **prod**.
[screenshots]

