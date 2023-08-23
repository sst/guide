---
layout: post
title: Getting Production Ready
date: 2021-08-24 00:00:00
lang: en
description: To get our full-stack serverless app ready for production, we'd want to automate our deployments.
ref: getting-production-ready
comments_id: getting-production-ready/158
---

Now that we've gone through the basics of creating a full-stack serverless app, you are ready to manage it in production.

So far you've had to deploy through your command line using the `pnpm sst deploy` command. When you have a team working on your project, you want to make sure the deployments to production are centralized. This ensures that you have control over what gets deployed to production. We'll go over how to automate your deployments using [Seed](https://seed.run){:target="_blank"}.

The goal of the next few sections is to make sure that you have a setup that you can easily replicate and use for your future projects.

Let's get started by creating a CI/CD pipeline for our serverless app.
