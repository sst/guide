---
layout: post
title: Structure Environments Across AWS Accounts
description: It is recommended to use separate AWS accounts to manage environments in your Serverless app. It helps you keep your environments separate while allowing you to better deal with resource limits.
date: 2019-09-30 00:00:00
comments_id: structure-environments-across-aws-accounts/1336
---

The typical recommendation for teams is to deploy each of their environments to a separate AWS account. We find that this ends up being excessive for most teams. In our experience, what seems to work for many teams is:

- One account for the Production environment. You want to apply very strict IAM access permissions to this account.
- One account for **EACH** Staging environment. If you have multiple staging environment ie. `preprod`, `qa`, `uat`, etc, use a separate AWS account for each. You don't want to have multiple Staging environments share the same account because each Staging environment needs to mirror Production as closely as possible.
- One account for **ALL** Development environments. All feature and hotfix environments share the same AWS account. You will have many Development environments, many will be very short-lived. Creating a temporary AWS account for each environment and tearing it down after the change is merged into master is far too excessive. Especially when you need to push a quick hotfix. Also, as we mentioned in the [How to organize your services]({% link _chapters/organizing-serverless-projects.md %}) chapter, you have one repo for the infrastructure and one repo for the code. Each Development environment most likely does not need their own version of the infrastructure. Consider when the scenario where you push a hotfix. You can have multiple API environments all talk to the one Infrastructure environment. And having them all sit inside the same AWS account makes it easy for them to talk to each other without configuring cross-account IAM permissions. Of course, this is not a hard rule. If you have a major feature release, the release can have its own Infrastructure environment and the entire setup can be deployed to a separate AWS account.
- One account for **EACH** Developer environment. Each developer on your team has their own playground account.

At first glance, this might just seem like a whole lot of extra work and you might wonder if the added complexity is worth while. However, for teams this really helps protect your production environment. And we’ll go over the various ways it does so.

### Environment separation

Imagine that you (or somebody on your team) removes a DynamoDB table or Lambda function in your `serverless.yml` definition. Now, instead of deploying it to your _dev_ environment, you accidentally deploy it to _production_. This happens more often than you think!

To avoid mishaps like these, not every developer on your team should have _write_ access from their terminal to the _production_ environment. However, if all your environments are in the same AWS account, you need to carefully craft a detailed IAM policy to restrict/grant access to specific resources. This can be hard to do and you are likely to make mistakes.

By keeping each environment in a separate account, you can manage user access on a per account basis. And for _dev_ environments you could potentially grant your developers _AdministratorAccess_ without worrying about the specific resources.

### Resource limits

Another benefit of separating environments across AWS accounts is helping you work with AWS’ service limits. You might be familiar with the various hard and soft limits of the AWS services you use. Like the [Lambda’s 75 GB code storage limit](https://docs.aws.amazon.com/lambda/latest/dg/limits.html) or [the total number of S3 buckets per account limit](https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html). These limits are applicable on a per account basis. Therefore, an issue with having a single AWS account for all your environments is that, hitting these limits can affect your production environment. Hence, affecting your users!

For example, you are likely to deploy to your _dev_ environment an order of magnitude more often than to your _production_ environment. Meaning that you’ll hit the Lambda code storage limit on your _dev_ environment quicker than on _production_. If you only have one account for all your environments, hitting this limit would critically affect your production builds to fail.

By using multiple AWS accounts, you can be sure that the service limits will not interfere across environments.

### Consolidated billing

Finally, having separate accounts for your environments is recommended by AWS. And AWS has great support for it as well. In the AWS Organizations console, you can view and manage all the AWS accounts in your master account.

![Accounts in AWS Organization console](/assets/best-practices/structure-environments-across-aws-accounts/accounts-in-aws-organizations-console.png)

You don’t have to setup the billing details for each account. Billing is consolidated to the master account. You can also view a breakdown of usage and cost for each service in each account.

In the next chapter, we are going to look at how to setup these AWS accounts using AWS Organizations.
