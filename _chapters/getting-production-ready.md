---
layout: post
title: Getting Production Ready
date: 2018-02-23 00:00:00
lang: en
description: To get our serverless app production ready, we are going to have to configure it using Infrastructure as Code. We are also going to need to configure separate environments for dev/production and automate our deployments.
ref: getting-production-ready
comments_id: getting-production-ready/158
---

Now that we've gone through the basics of creating a Serverless app, you are ready to deploy your app to production. This means that we would like to have a couple of environments (development and production) and we want to be able to automate our deployments. While setting up the backend we did a bunch of manual work to create all the resources. And you might be wondering if you need to do that every time you create a new environment or app. Thankfully, there is a better way!

Over the next few chapters we will look at how to get your app ready for production, starting with:

- **Infrastructure as code**

  Currently, you go through a bunch of manual steps with a lot of clicking around to configure the backend. This makes it pretty tricky to recreate this stack for a new project. Or to configure a new environment for the same project. Serverless Framework is really good for converting this entire stack into code. This means that it can automatically recreate the entire project from scratch without ever touching the AWS Console.

- **Automating deployments**

  So far you've had to deploy through your command line using the `serverless deploy` command. When you have a team working on your project, you want to make sure the deployments to production are centralized. This ensures that you have control over what gets deployed to production. We'll go over how to automate your deployments using [Seed](https://seed.run) (for the backend) and [Netlify](https://netlify.com) (for the frontend).

- **Configuring environments**

  Typically while working on projects you end up creating multiple environments. For example, you'd want to make sure not to make changes directly to your app while it is in use. Thanks to the Serverless Framework and Seed we'll be able to do this with ease for the backend. And we'll do something similar for our frontend using React and Netlify.

- **Custom domains**

  Once your app is in production, you want it hosted under your domain name. This applies both to the React app (my-domain.com) and backend APIs (api.my-domain.com).

The goal of the next few sections is to make sure that you have a setup that you can easily replicate and use for your future projects. This is almost exactly what we and a few of our readers have been using.

### Reorganize Your Repo

In the next few chapters we are going to be using [AWS CDK](https://aws.amazon.com/cdk/) to configure our Serverless infrastructure. So let's reorganize our backend repo around a bit.

{%change%} Create a new `services/notes/` directory. Run the following in the root of our backend repo.

``` bash
$ mkdir -p services/notes
```

This is a common organizational pattern in Serverless Framework projects. You'll have multiple services in the future. So we'll create a services directory and add a notes service in it.

{%change%} Let's move our files to the new directory.

``` bash
$ mv *.js *.json *.yml .env services/notes
$ mv tests libs mocks node_modules services/notes
```

If you are on Windows or if the above commands don't work, make sure to copy over these files and directories to `services/notes`.

In the coming chapters, we'll also be creating an `infrastructure/` directory for our CDK app.

### Update the serverless.yml

We'll also be deploying our app to multiple environments. This makes it so that when we make changes or test our app while developing, we don't affect our users. So let's start by defaulting our API to deploy to the development environment, instead of production.

{%change%} Open the `services/notes/serverless.yml` and find the following line:

``` yml
  stage: prod
``` 

{%change%} And replace it with:

``` yml
  stage: dev
```

We are defaulting the stage to `dev` instead of `prod`. This will become more clear later when we create multiple environments.

### Commit the Changes

Let’s quickly commit these to Git.

``` bash
$ git add .
$ git commit -m "Reorganizing the repo"
```

Note that, we are going to be creating new versions of our resources (DynamoDB, Cognito, etc.). Instead of using the ones that we created in the previous sections. This is because we want to define and create them programmatically. You can remove the resources we previously created. But for the purpose of this guide, we are going to leave it as is. In case you want to refer back to it at some point.

Let's get started by getting a quick feel for how _infrastructure as code_ works.
