---
layout: post
title: Deploying to Multiple AWS Accounts
description: Once you've configured the environments in your Serverless app across multiple AWS accounts, you'll want to deploy them. In this chapter, we look at how to create the AWS credentials and manage the environments using Seed.
date: 2019-09-30 00:00:00
comments_id: deploying-to-multiple-aws-accounts/1322
---

Now that you have a couple of AWS accounts created and your resources have been parameterized, let's look at how to deploy them. In this chapter, we'll deploy the following:

1. The [resources repo]({{ site.backend_ext_resources_github_repo }}) will be deployed in phases to the `dev` and `prod` stage. These two stages are configured in our `Development` and `Production` AWS accounts respectively.

2. Then we'll do the same with the [APIs repo]({{ site.backend_ext_api_github_repo }}).

### Configure AWS Profiles

Follow the [setup up IAM users]({% link _chapters/create-an-iam-user.md %}) chapter to create an IAM user in your `Development` AWS account. And take a note of the **Access key ID** and **Secret access key** for the user.

Next, set these credentials in your local machine using the AWS CLI:

``` bash
$ aws configure --profile default
```

This sets the default IAM credentials to those of the Development account. Meaning when you run `serverless deploy`, a service will get deployed into the Development account.

Repeat the step to create an IAM user in your `Production` account. And make a note of the credentials. We will not add the IAM credentials for the Production account on our local machine. This is because we do not want to be able to deploy code to the Production environment EVER from our local machine.

Production deployments should always go through our CI/CD pipeline.

Next we are going to deploy our two repos to our environments. We want you to follow along so you can get a really good sense of what the workflow is like.

So let's start by using the demo repo templates from GitHub.

### Create demo repos

Let's first create [the resources repo]({{ site.backend_ext_resources_github_repo }}). Click **Use this template**.

![Use demo resources repo template](/assets/best-practices/deploy-environments-to-multiple-aws-accounts/use-demo-resources-repo-template.png)

Enter Repository name **serverless-stack-demo-ext-resources** and click **Create repository from template**.

![Create demo resources repo on GitHub](/assets/best-practices/deploy-environments-to-multiple-aws-accounts/create-demo-resources-repo-on-github.png)

And do the same for [the API services repo]({{ site.backend_ext_api_github_repo }}).

![Create demo API services repo template](/assets/best-practices/deploy-environments-to-multiple-aws-accounts/use-demo-api-services-repo-template.png)

Enter Repository name **serverless-stack-demo-ext-api** and click **Create repository from template**.

![Create demo API services repo on GitHub](/assets/best-practices/deploy-environments-to-multiple-aws-accounts/create-demo-api-services-repo-on-github.png)

Now that we've forked these repos, let's deploy them to our environments. We are going to use [Seed](https://seed.run) to do this but you can set this up later with your favorite CI/CD tool.
