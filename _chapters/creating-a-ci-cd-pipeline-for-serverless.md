---
layout: post
title: Creating a CI/CD pipeline for Serverless
date: 2020-11-04 00:00:00
lang: en
description: In this chapter we'll be setting up a CI/CD pipeline for your Serverless apps. We'll be using a service called Seed. It's a CI/CD platform built specifically for Serverless apps and works completely out of the box.
ref: creating-a-ci-cd-pipeline-for-serverless
redirect_from: /chapters/automating-serverless-deployments.html
comments_id: creating-a-ci-cd-pipeline-for-serverless/174
---

So to recap, this is what we have built so far:

- A serverless app that includes the following:
  - Storage stack, with DynamoDB and S3
  - API stack
  - Auth stack, with Cognito
  - Frontend stack for our React.js app
- A way to handle secrets locally
- And a way to run unit tests
- Deployed to a local dev environment
- And deployed to a prod environment

All of this is neatly committed in a Git repo.

So far we've been deploying our app locally through our command line. But if we had multiple people on our team, or if we were working on different features at the same time, we won't be able to work on our app because the changes would overwrite each other.

To fix this we are going to implement a CI/CD pipeline for our full-stack serverless app. 

### What is a CI/CD pipeline

CI/CD or Continuous Integration/Continuous Delivery is the process of automating deployments by tying it to our source control system. So that when new code changes are pushed, our app is automatically tested, built and deployed.

A CI/CD pipeline usually includes multiple environments. An environment is one where there are multiple instances of our deployed app. So we can have an environment called _production_ that our users will be using. And _development_ environments that we can use while developing our app.

In the coming chapters we'll be setting up a pipeline that looks like this.

![Serverless CI/CD pipeline](/assets/diagrams/serverless-ci-cd-pipeline.png)

Here is what our workflow is going to look like:

- Our repo will be connected to our CI/CD service.
- Any commits that are pushed to the `master` branch will be automatically tested, built, and deployed to our AWS dev environment.
- When we are ready, we'll manually promote these changes to production.
- Our CI/CD service will once again test, build, and deploy them. But this time, to our production environment.

Note that, strictly speaking a CI/CD process doesn't involve any manual steps. We are including it here because we are deploying infrastructure as well. And we want to make sure that we can review these changes before they are deployed to production. 

### CI/CD for Serverless

There are many common CI/CD services, like [Travis CI](https://travis-ci.org) or [CircleCI](https://circleci.com). These usually require you to manually configure the above pipeline. It involves a fair bit of scripts and configuration.

To fix this we created a service called [**Seed**](https://seed.run). It requires no scripts and is built specifically for Serverless. It also allows you to monitor and debug your Serverless app. This is something we'll be doing later in the guide.

We should mention that you don't have to use Seed. And this section is completely optional.

Let's get started with setting up your project on Seed.
