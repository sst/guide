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

Follow [setup up IAM users]({% link _chapters/create-an-iam-user.md %}) chapter to create an IAM user in your `Production` account. And take a note of the **Access key ID** and **Secret access key** for the user.

Setup the credentials in your local machine using the AWS CLI:

``` bash
$ aws configure --profile Production
```

Repeat the step to create an IAM user in your `Development` account. And setup the credentials using the AWS CLI again:

``` bash
$ aws configure --profile Development
```

### Deploy

To deploy to the `featureX` environment, navigate to the root of the `notes-api` service:

``` bash
$ cd services/notes-api
```

You should see the `serverless.yml` file for the `notes-api` service in this directory. And deploy it using:

``` bash
$ serverless deploy -s featureX --aws-profile Development
```

Serverless Framework has a concept of stages. They are synonymous with environments. Recall that, in the previous chapter we used this stage name to parameterize our resource names. 

The above command applies the stage name `featureX` and deploys the CloudFormation template to our `Development` account. It uses the IAM credentials we configured above.

Deploy again to the `dev` environment:

``` bash
$ serverless deploy -s dev --aws-profile Development
```

This command applies the stage name `dev` and deploys to our `Development` account. Note, if we don't parameterize the name of a resource, this command will fail. Since both the `featureX` and `dev` stages are deployed to the same AWS account, causing the resource names to thrash.

Finally, we can deploy to the `prod` environment.

``` bash
$ serverless deploy -s prod --aws-profile Production
```
