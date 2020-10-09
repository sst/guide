---
layout: post
title: Promoting to Production
description: In this chapter we'll look at the process of promoting your Serverless app to production using Seed. We'll look at why a manual promote is recommended and how change sets can help us review our changes.
date: 2019-10-02 00:00:00
comments_id: promoting-to-production/1330
---

Now that our new feature has been tested and merged to master, we are ready to promote it to production. We are going to do so by promoting our `dev` stage to `prod`.

Head over to Seed. And then hit **Promote** at the bottom of the `dev` stage.

![Select Promote in dev stage](/assets/best-practices/promote-to-production/select-promote-in-dev-stage.png)

You will see a list of changes. Note, only the major changes are shown here. The change list shows that we added a Lambda functions and an API Gateway method. A couple of other minor resources like the Lambda execution IAM role and Lambda's CloudWatch log group were also added but those are hidden by default.

Hit **Promote to Production**.

![Select Promote to Production](/assets/best-practices/promote-to-production/select-promote-to-production.png)

This will trigger the `prod` stage to start building.

![Show deploying in prod stage](/assets/best-practices/promote-to-production/show-deploying-in-prod-stage.png)

### Why manual promote?

In a traditional monolithic application (non-Serverless) development, your code mostly contains application logic. Application logic can be rolled back relatively easily and is usually side-effect free. 

Serverless apps adopt the [infrastructure as code pattern]({% link _chapters/what-is-infrastructure-as-code.md %}), and your infrastructure definition (`serverless.yml`) sits in your codebase. When your Serverless app is deployed, the code is updated, and the infrastructure changes are applied. A typo in your `serverless.yml` could remove your resources. And in the case of a database resource, this could result in permanent data loss.

To avoid these issues in the first place, it’s recommended that you have a step to review your infrastructure changes before they get promoted to production.

### What is a change set?

CloudFormation provides a feature called [Change Sets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html). You give CloudFormation the new template you are going to deploy into a stack, and CloudFormation will show you the resources that are going to be added, modified, and removed. You can think of it as a dry run.

We recommend generating CloudFormation Change Sets as a part of the manual approval step in your CI/CD pipeline. This will let you review the exact infrastructure changes that are going to be applied. We think this extra step can really help prevent any irreversible infrastructure changes from being deployed to your production environment.

However, CloudFormation templates and Change Sets can be pretty hard to read. Here is where Serverless Framework does a really good job of allowing you to provision a Lambda and API resources in a simple and compact syntax. Behind the scene, a great number of resources are provisioned: Lambda roles, Lambda versions, Lambda log groups, API Gateway resource, API Gateway method, API Gateway deployment, just to name a few. However when CloudFormation shows you a list of changes with these resources (usually with cryptic names), it obscures the actual changes that you need to be paying attention to. This is why with Seed we’ve taken extra care to improve on the CloudFormation Change Set. We do this by showing changes that are relevant to us as developers and highlight the changes that need extra attention.

Next, let's look at the scenario where you might end up having to rollback your code.
