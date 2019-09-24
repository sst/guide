---
layout: post
title: Getting Production Ready
date: 2018-02-23 00:00:00
lang: en
description: To get our serverless app production ready, we are going to have to configure it using Infrastructure as Code. We are also going to need to configure separate environments for dev/production and automate our deployments.
ref: getting-production-ready
comments_id: getting-production-ready/158
---

Now that we've gone through the basics of creating a Serverless app, you are ready to deploy your app to production. This means that we would like to have a couple of environments (development and production) and we want to be able to automate our deployments. While setting up the backend we did a bunch of manual work to create all the resources. And you might be wondering if you need to do that everytime you create a new environment or app. Thankfuly, there is a better way!

Over the next few chapters we will look at how to get your app ready for production, starting with:

- **Infrastructure as code**

  Currently, you go through a bunch of manual steps with a lot of clicking around to configure the backend. This makes it pretty tricky to recreate this stack for a new project. Or to configure a new environment for the same project. Serverless Framework is really good for converting this entire stack into code. This means that it can automatically recreate the entire project from scratch without ever touching the AWS Console.

- **Automating deployments**

  So far you've had to deploy through your command line using the `serverless deploy` command. When you have a team working on your project, you want to make sure the deployments to production are centralized. This ensures that you have control over what gets deployed to production. We'll go over how to automate your deployments using [Seed](https://seed.run) (for the backend) and [Netlify](https://netlify.com) (for the frontend).

- **Configuring environments**

  Typically while working on projects you end up creating multiple environments. For example, you'd want to make sure not to make changes directly to your app while it is in use. Thanks to the Serverless Framework and Seed we'll be able to do this with ease for the backend. And we'll do something similar for our frontend using React and Netlify.

- **Custom domains**

  Once your app is in production, you want it hosted under your domain name. This applies both to the React app (my-domain.com) and backend APIs (api.my-domain.com).

The goal of next few sections is to make sure that you have a setup that you can easily replicate and use for your future projects. This is almost exactly what we and a few of our readers have been using.

Let's get started by first converting our backend infrastructure into code.
