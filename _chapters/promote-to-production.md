---
layout: post
title: Promote to production
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

Once you have tested the code in `dev` stage, it is ready to deploy our code to the `prod` stage. We are going to do so by promoting our `dev` stage to `prod`.

# Promote

Head to the Seed page. And then select **Promote** at the bottom of the `dev` stage.

![](/assets/best-practices/promote-to-production-1.png)

You will see a list of changes in resources. Note only the major changes are shown here. In this case, since this is the first time we are deploying to the `prod` stage, the change list shows that Lambda functions, API paths and an SNS topic will be created. 

![](/assets/best-practices/promote-to-production-2.png)

 Scroll to the bottom of the change list and select **Promote to Production**.

![](/assets/best-practices/promote-to-production-3.png)

This will trigger the `prod` stage to start building.

![](/assets/best-practices/promote-to-production-4.png)

# Why manual promote?

In a traditional monolithic application (non-Serverless) development, your code mostly contains application logic. Application logic can be rolled back relatively easily and is usually side-effect free. 

Serverless application adopt the [infrastructure as code pattern](https://serverless-stack.com/chapters/what-is-infrastructure-as-code.html), and your infrastructure definition (`serverless.yml`) sits in your codebase. When your Serverless app is deployed, the code is updated, and the infrastructure changes are applied. A typo in `serverless.yml` could remove your resources. And in the case of a database resource, this could result in permanent data loss.

To avoid these issues in the first place, it’s recommended that you have a step to review your infrastructure changes before they get promoted to production. Just like you often do code review, an infrastructure review is also important, if not more.

# What is a change set?

CloudFormation provides a feature called [Change Sets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html). You give CloudFormation the new template you are going to deploy into a stack, and CloudFormation will show you the resources that are going to be added, modified and removed. You can think of it as a dry run.

We recommend generating CloudFormation Change Sets as a part of the manual approval step in your CI/CD pipeline. This will let you review the exact infrastructure changes that are going to be applied. We think this extra step can really help prevent any irreversible infrastructure changes from being deployed to your production environment mistakingly.

As an aside, CloudFormation templates and Change Sets can be pretty hard to read. Here is where Serverless Framework does a really good job of allowing to provision a Lambda and API resources in a simple and compact syntax. Behind the scene, a great number of resources are provisioned: Lambda roles, Lambda versions, Lambda log groups, API Gateway resource, API Gateway method, API Gateway deployment, just to name a few. However when CloudFormation shows you a list of changes with these resources (usually with cryptic names), it obscures the actual changes that you need to be paying attention to. This is why with Seed we’ve taken extra care to improve on the CloudFormation Change Set. We do this by showing changes that are relevant to the us as developers and highlight the changes that you should be paying extra attention to.
