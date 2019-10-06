---
layout: post
title: Deploy environments to multiple AWS accounts
description: 
date: 2019-09-30 00:00:00
comments_id: 
---

Now that you have a couple of AWS accounts created and your resources have been parameterized, let's look at how to deploy them. In this chapter, we'll deploy the following:

1. The [resources repo]({{ site.backend_ext_resources_github_repo }}) will be deployed in phases to the `dev` and `prod` stage. These two stages are configured in our `Development` and `Production` AWS accounts respectively.

2. Do the same with the [APIs repo]({{ site.backend_ext_api_github_repo }}).

We'll later configure a couple of ephemeral stages for our API services.

TODO: UPDATE CREDENTIALS SECTION

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

Deploy to **dev**.
[screenshots]

Deploy to **prod**.
[screenshots]


Add the api repo on Seed with **dev** annd **prod** stages.
[screenshots]

Add the 3 services.
[screenshots]

Setup deploy phase
[screenshots]

Deploy to **dev**.
[screenshots]

Deploy to **prod**.
[screenshots]

Now that our entire app has been deployed, let's look at how we are sharing environment specific config across our services.
