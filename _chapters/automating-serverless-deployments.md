---
layout: post
title: Automating serverless deployments
date: 2017-05-30 00:00:00
description:
comments_id:
---

So to recap, we have a serverless project that has all it's infrastructure completely configured in code. We also have a way to handle secrets locally. And finally, we have a way to run unit tests to test our business logic. All of this is neatly committed in a git repo.

Next we are going to use our git repo to automate our deployments. This essentially means that we can deploy our entire project simply pushing our changes to git. This can be incredibly useful since you won't need to any special scripts or configurations to deploy your code. You can also have multiple people on your team dpeloy with ease.

Along with automating deployments, we are also going to look at working with multiple environments. We want to create clear separation between our production environment and our dev environment. We are going to create a workflow where we continually deploy to our dev (or any non-prod) environment. But we will be using a manual promotion step when we promote to production. We'll also look at confguring custom domains for API.

For automating our serverless backend, we are going to be using a service called [Seed](https://seed.run). Full disclosure, we (the authors) also built Seed. You can replace most of this section with a service like [Travis CI](https://travis-ci.org) or [Circle CI](https://circleci.com). It is a bit more cumbersome and needs some scripting but we might cover this in the future.

Let's get started with setting up your project on Seed.
