---
layout: post
title: Getting Production Ready
date: 2021-08-24 00:00:00
lang: en
description: To get our full-stack serverless app ready for production, we'd want to automate our deployments. And we want to be able to monitor any errors that our users run into.
ref: getting-production-ready
comments_id: getting-production-ready/158
---

Now that we've gone through the basics of creating a full-stack serverless app, you are ready to manage it in production. This means that we would like to be able to automate our deployments. And we want to be able to monitor any errors that our users run into.

Over the next few chapters we will look at how to get your app ready for production, starting with:

- **Automating deployments**

  So far you've had to deploy through your command line using the `npm run deploy` command. When you have a team working on your project, you want to make sure the deployments to production are centralized. This ensures that you have control over what gets deployed to production. We'll go over how to automate your deployments using [Seed](https://seed.run).

- **Monitoring and debugging errors in production**

  Debugging errors in your app can be tricky in production. You cannot expect your users to tell you when they see a problem. And you cannot ask them to send you what they see in the browser console. We'll be setting up our app so that we can monitor and debug any issues that come up in production.

The goal of the next few sections is to make sure that you have a setup that you can easily replicate and use for your future projects.

Let's get started by creating a CI/CD pipeline for our serverless app.
