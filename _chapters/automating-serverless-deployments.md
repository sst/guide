---
layout: post
title: Automating Serverless Deployments
date: 2018-03-11 00:00:00
lang: en
description: We would like to automatically deploy our Serverless Framework project when we commit any changes to our Git repository. To do this we are going to use a service called Seed (https://seed.run) to automate our serverless deployments. It will configure a CI/CD pipeline and setup our environments.
context: true
ref: automating-serverless-deployments
comments_id: automating-serverless-deployments/174
---

So to recap, this is what we have so far:

- A serverless project that has all it's infrastructure completely configured in code
- A way to handle secrets locally
- And finally, a way to run unit tests to test our business logic

All of this is neatly committed in a Git repo.

Next we are going to use our Git repo to automate our deployments. This essentially means that we can deploy our entire project by simply pushing our changes to Git. This can be incredibly useful since you won't need to create any special scripts or configurations to deploy your code. You can also have multiple people on your team deploy with ease.

Along with automating deployments, we are also going to look at working with multiple environments. We want to create clear separation between our production environment and our dev environment. We are going to create a workflow where we continually deploy to our dev (or any non-prod) environment. But we will be using a manual promotion step when we promote to production. We'll also look at configuring custom domains for APIs.

For automating our serverless backend, we are going to be using a service called [Seed](https://seed.run). Full disclosure, we also built Seed. You can replace most of this section with a service like [Travis CI](https://travis-ci.org) or [Circle CI](https://circleci.com). It is a bit more cumbersome and needs some scripting but we might cover this in the future.

Let's get started with setting up your project on Seed.
