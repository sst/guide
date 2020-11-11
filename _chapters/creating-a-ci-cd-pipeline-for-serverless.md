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

- A Serverless app that creates our backend APIs
- A [CDK SST app](https://github.com/serverless-stack/serverless-stack) that configures all our infrastructure completely in code
- A way to handle secrets locally
- And a way to run unit tests to test our business logic

All of this is neatly committed in a Git repo.

So far we've been deploying our app locally through our command line. But if we had multiple people on our team, or if we were working on different features at the same time, we won't be able to work on our app because the changes would overwrite each other. And it also means that if we deploy some changes while we are working on our app, our users will see those changes.

To fix this we are going to implement a CI/CD pipeline with multiple environments for our Serverless app. 

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

We should mention that you don't have to use Seed. It just makes it easier for this guide. If you'd like to use Circle or Travis, we've created a couple of tutorials for them as well.

- [Configure a CI/CD pipeline for Serverless apps on CircleCI](https://seed.run/blog/how-to-build-a-cicd-pipeline-for-serverless-apps-with-circleci)
- [Configure a CI/CD pipeline for Serverless apps on Travis CI](https://seed.run/blog/how-to-build-a-cicd-pipeline-for-serverless-apps-with-travis-ci)

Let's get started with setting up your project on Seed.
