---
layout: post
title: Best practices for building Serverless apps
description: 
date: 2019-10-03 00:00:00
comments_id: 
---

In this section of the guide we'll be covering the best practices for developing and maintaining large Serverless applications. It roughly builds on what we've covered so far and it extends the [demo notes app](https://demo2.serverless-stack.com) that we built in the first section. It's intended for teams as opposed to individual developers. It's meant to give you a foundation that scales as your app (and team) grows.

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

TODO: UPDATE LINKS UPDATE FLOW

- Organizing large Serverless apps
  - Sharing resources using cross-stack references
  - Sharing code and config between services
  - Sharing API endpoints across services
- Configuring environments
  - Best practices for environments in Serverless
  - Using separate AWS accounts to manage environments 
  - Parameterizing resource names
  - Managing environment specific configs
  - Sharing domains across environments
- Best practices for handling secrets
- Development lifecycle
  - Working locally
  - Creating pull requests for review
  - Merging to master or the dev environment 
  - Promoting to production
  - Handling rollbacks
  - Deploying only updated services
- Best practices for debugging Serverless apps
  - Using Lambda and API Gateway logs
  - Using AWS X-Ray to trace Lambda functions

We think these concepts should be a good starting point for your projects and you should be able to adapt them to fit your use case!

### How this new section is structured

This section of the guide has a fair bit of _theory_ when compared to the first section. However, we try to take a similar approach. We'll slowly introduce these concepts as we work through the chapters.

The following repos will serve as the centerpiece of this section:

TODO: UPDATE LINKS

1. [Serverless Infrastructure]
   A repo containing all the main infrastructure resources of our extended notes application.
2. [Serverless Services]
   A monorepo containing all the services in our extended notes application.

We'll start by forking these repos but unlike the first section we won't be directly working on the code. Instead as we work through the sections we'll point out the key aspects of the codebase.

We'll then go over step by step how to configure the environments through AWS. We'll use [Seed](https://seed.run) to illustrate how to deploy our application to our environments. Note that, you do not need Seed to configure your own setup. We'll only be using it as an example. Once you complete the guide you should be able to use your favorite CI/CD service to build a pipeline that follows the best practices. Finally, we'll go over the development workflow for you and your team.

The end result of this will be that you'll have a fully functioning Serverless backend, hosted in your own GitHub repo, and deployed to your AWS environments. We want to make sure that you'll have a working setup in place, so you can always refer back to it when you need to!