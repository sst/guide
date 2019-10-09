---
layout: post
title: Best Practices for Building Serverless Apps
description: In this section of the guide we'll be covering the best practices for developing and maintaining large Serverless applications. It builds on what we've covered so far and it extends the demo notes app that we built in the first section. It's intended for teams as opposed to individual developers. It's meant to give you a foundation that scales as your app (and team) grows.
date: 2019-10-03 00:00:00
comments_id: best-practices-for-building-serverless-apps/1315
---

In this section of the guide we'll be covering the best practices for developing and maintaining large Serverless applications. It builds on what we've covered so far and it extends the [demo notes app](https://demo2.serverless-stack.com) that we built in the first section. It's intended for teams as opposed to individual developers. It's meant to give you a foundation that scales as your app (and team) grows.

### Background

Serverless Stack was launched back in March 2017. Since then thousands of folks have used the guide to build their first full-stack Serverless app. Many of you have used this as a starting point to build really large applications. Applications that are made up of scores of services worked on by a team of developers.

However, the challenges that teams face while developing large scale Serverless applications are very different from the one an individual faces while building his first app. You've to deal with architectural design decisions and questions that can be hard to answer if you haven't built and managed a large scale Serverless app before. Questions like:

- How should my project be structured when I have dozens of interdependent services?
- How should I manage my environments?
- What is the best practice for storing secrets?
- How do I make sure my production environments are completely secure?
- What does the workflow look like for the developers on my team?
- How do I debug large Serverless applications?

Some of these are not exclusive to folks working on large scale apps, but they are very common once your app grows to a certain size. We hear most of these through our readers, our users, and our [Serverless Toronto Meetup](http://serverlesstoronto.org) members.

While there are tons of blog posts out there that answer some of these questions, it requires you to piece them together to figure out what the best practices are.

### A new perspective

Now nearly 3 years into working on Serverless Stack and building large scale Serverless applications, there are some common design patterns that we can confidently share with our readers. Additionally, Serverless as a technology and community has also matured to the point where there are reasonable answers for the above questions.

This new addition to the guide is designed to lay out some of the best practices and give you a solid foundation to use Serverless at your company. You can be confident that as your application and team grows, you'll be on the right track for building something that scales. 

### Who is this for

While the topics covered in this section can be applied to any project you are working on, they are far better suited for larger scale ones. For example, we talk about using multiple AWS accounts to configure your environments. This works well when you have multiple developers on your team but isn't worth the overhead when you are the only one working on the project.

### What is covered in this section

Here is a rough rundown of the topics covered in this section of the guide.

We are covering primarily the backend Serverless portion. The frontend flow works relatively the same way as what we covered in the first section. We also found that there is a distinct lack of best practices for building Serverless backends as opposed to React apps.

- [Organizing large Serverless apps]({% link _chapters/organizing-serverless-projects.md %})
  - [Sharing resources using cross-stack references]({ link _chapters/cross-stack-references-in-serverless.md %})
  - [Sharing code between services]({% link _chapters/share-code-between-services.md %})
  - [Sharing API endpoints across services]({% link _chapters/share-an-api-endpoint-between-services.md %})
- [Configuring environments]({% link _chapters/environments-in-serverless-apps.md %})
  - [Using separate AWS accounts to manage environments ]({% link _chapters/structure-environments-across-aws-accounts.md %})
  - [Parameterizing resource names]({% link _chapters/parameterize-serverless-resources-names.md %})
  - [Managing environment specific configs]({% link _chapters/manage-environment-related-config.md %})
  - [Best practices for handling secrets]({% link _chapters/storing-secrets-in-serverless-apps.md %})
  - [Sharing domains across environments]({% link _chapters/share-route-53-domains-across-aws-accounts.md %})
- [Development lifecycle]({% link _chapters/working-on-serverless-apps.md %})
  - [Working locally]({% link _chapters/invoke-api-gateway-endpoints-locally.md %})
  - [Creating feature environments]({% link _chapters/creating-feature-environments.md %})
  - [Creating pull request environments]({% link _chapters/creating-pull-request-environments.md %})
  - [Promoting to production]({% link _chapters/promoting-to-production.md %})
  - [Handling rollbacks]({% link _chapters/rollback-changes.md %})
- [Using AWS X-Ray to trace Lambda functions]({% link _chapters/tracing-serverless-apps-with-x-ray.md %})

We think these concepts should be a good starting point for your projects and you should be able to adapt them to fit your use case!

### How this new section is structured

This section of the guide has a fair bit of _theory_ when compared to the first section. However, we try to take a similar approach. We'll slowly introduce these concepts as we work through the chapters.

The following repos will serve as the centerpiece of this section:

1. [**Serverless Infrastructure**]({{ site.backend_ext_resources_github_repo }})

   A repo containing all the main infrastructure resources of our extended notes application. We are creating a DynamoDB table to store all the notes related info, an S3 bucket for uploading attachments, and a Cognito User Pool and Identity Pool to authenticate users.

2. [**Serverless Services**]({{ site.backend_ext_api_github_repo }})

   A monorepo containing all the services in our extended notes application. We have three different services here. The `notes-api` service that powers the notes CRUD API endpoint, the `billing-api` service that processes payment information through Stripe and publishes a message on an SNS topic. Finally, we have a `notify-job` service that listens to the SNS topic and sends us a text message when somebody makes a purchase.

We'll start by forking these repos but unlike the first section we won't be directly working on the code. Instead as we work through the sections we'll point out the key aspects of the codebase.

We'll then go over step by step how to configure the environments through AWS. We'll use [Seed](https://seed.run) to illustrate how to deploy our application to our environments. Note that, you do not need Seed to configure your own setup. We'll only be using it as an example. Once you complete the guide you should be able to use your favorite CI/CD service to build a pipeline that follows the best practices. Finally, we'll go over the development workflow for you and your team.

The end result of this will be that you'll have a fully functioning Serverless backend, hosted in your own GitHub repo, and deployed to your AWS environments. We want to make sure that you'll have a working setup in place, so you can always refer back to it when you need to!

Let's get started.
