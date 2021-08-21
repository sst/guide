---
layout: post
title: Getting Production Ready
date: 2018-02-23 00:00:00
lang: en
description: 
ref: getting-production-ready
comments_id: getting-production-ready/158
---

Now that we've gone through the basics of creating a serverless app, you are ready to deploy your app to production. This means that we would like to have a couple of environments (development and production) and we want to be able to automate our deployments. While setting up the backend we did a bunch of manual work to create all the resources. And you might be wondering if you need to do that every time you create a new environment or app. Thankfully, there is a better way!

TODO: UPDATE FOR SST

Over the next few chapters we will look at how to get your app ready for production, starting with:

- **Automating deployments**

  So far you've had to deploy through your command line using the `serverless deploy` command. When you have a team working on your project, you want to make sure the deployments to production are centralized. This ensures that you have control over what gets deployed to production. We'll go over how to automate your deployments using [Seed](https://seed.run) (for the backend) and [Netlify](https://netlify.com) (for the frontend).

- **Configuring environments**

  Typically while working on projects you end up creating multiple environments. For example, you'd want to make sure not to make changes directly to your app while it is in use. Thanks to the Serverless Framework and Seed we'll be able to do this with ease for the backend. And we'll do something similar for our frontend using React and Netlify.

- **Monitoring and debugging errors in production**

  Debugging errors in your app can be tricky, once it's in production. You cannot expect your users to tell you when they see a problem. And you cannot ask them to send you what they see in the browser console. We'll be setting up our app so that we can monitor and debug any issues that come up in production.

The goal of the next few sections is to make sure that you have a setup that you can easily replicate and use for your future projects.

Let's get started by creating a CI/CD pipeline for our serverless app.
