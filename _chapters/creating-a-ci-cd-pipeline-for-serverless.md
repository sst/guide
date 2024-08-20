---
layout: post
title: Creating a CI/CD Pipeline for serverless
date: 2020-11-04 00:00:00
lang: en
description: In this chapter we'll be using the SST Console to set up a CI/CD pipeline for our full-stack serverless app.
ref: creating-a-ci-cd-pipeline-for-serverless
redirect_from: /chapters/automating-serverless-deployments.html
comments_id: creating-a-ci-cd-pipeline-for-serverless/174
---

So to recap, here's what we've created so far.

- A full-stack serverless app that includes:
  - [Storage with DynamoDB and S3]({% link _chapters/create-a-dynamodb-table-in-sst.md %})
  - [API]({% link _chapters/add-an-api-to-create-a-note.md %})
  - [Auth with Cognito]({% link _chapters/auth-in-serverless-apps.md %})
  - [Frontend in React]({% link _chapters/create-a-new-reactjs-app.md %})
- [A way to handle secrets locally]({% link _chapters/handling-secrets-in-sst.md %})
- [A way to run unit tests]({% link _chapters/unit-tests-in-serverless.md %})
- [Deployed to a prod environment with a custom domain]({% link _chapters/custom-domains-in-serverless-apis.md %})

All of this is neatly [committed in a Git repo]({{ site.sst_demo_repo }}){:target="_blank"}.

So far we've been deploying our app locally through our command line — `npx sst deploy`. But if we had multiple people on our team, or if we were working on different features at the same time, we won't be able to work on our app because the changes would overwrite each other.

To fix this we are going to implement a CI/CD pipeline for our full-stack serverless app. 

### What is a CI/CD Pipeline

CI/CD or Continuous Integration/Continuous Delivery is the process of automating deployments by tying it to our source control system. So that when new code changes are pushed, our app is automatically deployed.

A CI/CD pipeline usually includes multiple environments. An environment is one where there are multiple instances of our deployed app. So we can have an environment called _production_ that our users will be using. And _development_ environments that we can use while developing our app.

Here is what our workflow is going to look like:

- Our repo will be connected to our CI/CD service.
- Any commits that are pushed to the `production` branch will be automatically deployed to the `production` stage.
- Any PRs will be automatically deployed as preview environments.

Our workflow is fairly simple. But as your team grows, you'll need to add additional dev, staging, or preview environments.

### CI/CD for Serverless

There are many common CI/CD services, like [GitHub Actions](https://github.com/features/actions){:target="_blank"}, [Travis CI](https://travis-ci.org){:target="_blank"} or [CircleCI](https://circleci.com){:target="_blank"}. These usually require you to manually configure the above pipeline. It involves a fair bit of scripts and configuration.

SST makes this easier with the [SST Console]({{ site.sst_url }}/docs/console/){:target="_blank"}'s [Autodeploy](/docs/console/#autodeploy){:target="_blank"} feature. It also shows you all the resources in your app and allows you to monitor and debug them.

We should mention that you don't have to use the SST Console. And this section is completely optional.

Let's get started with setting up the SST Console.
