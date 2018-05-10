---
layout: post
title: Getting Production Ready
date: 2018-02-23 00:00:00
comments_id: getting-production-ready/158
---

Now that we've gone through the basics of creating a Serverless Stack, you are probably wondering if you need to do all these manual steps everytime you create a new project. Plenty of our readers have used this stack for their personal and professional projects. So in Part II we are going to address some of the common issues that they run into. Specifically, we will go over the following:

- **Infrastructure as code**

  Currently, you go through a bunch of manual steps with a lot of clicking around to configure your backend. This makes it pretty tricky to re-create this stack for a new project. Or to configure a new environment for the same project. Serverless Framework is really good for converting this entire stack into code. This means that it can automatically re-create the entire project from scratch without ever touching the AWS Console.

- **Working with 3rd party APIs**

  A lot of our readers are curious about how to use serverless with 3rd party APIs. We will go over how to connect to the Stripe API and accept credit card payments.

- **Unit tests**

  We will also look at how to configure unit tests for our backend using [Jest](https://facebook.github.io/jest/).

- **Automating Deployments**

  In the current tutorial you need to deploy through your command line using the `serverless deploy` command. This can be a bit tricky when you have a team working on your project. To start with, we'll add our frontend and backend projects to GitHub. We'll then go over how to automate your deployments using [Seed](https://seed.run) (for the backend) and [Netlify](https://netlify.com) (for the frontend).

- **Configuring environments**

  Typically while working on projects you end up creating multiple environments. For example, you'd want to make sure not to make changes directly to your app while it is in use. Thanks to the Serverless Framework and Seed we'll be able to do this with ease for the backend. And we'll do something similar for our frontend using React and Netlify. We'll also configure custom domains for our backend API environments.

- **Working with secrets**

  We will look at how to work with secret environment variables in our local environment and in production.

The goal of Part II is to ensure that you have a setup that you can easily replicate and use for your future projects. This is almost exactly what we and a few of our readers have been using.

This part of the guide is fairly standalone but it does rely on the original setup. If you haven't completed Part I; you can quickly browse through some of the chapters but you don't necessarily need to redo them all. We'll start by forking the code from the original setup and then building on it.

Let's get started by first converting our backend infrastructure into code.
