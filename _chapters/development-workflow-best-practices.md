---
layout: post
title: Development workflow best practices
description: 
date: 2019-10-07 00:00:00
comments_id: 
---

So to quickly recap, we've split our real world Serverless app into two repos, [one creates our infrastructure resources]({{ site.backend_ext_resources_github_repo }}) and the [second creates our API services]({{ site.backend_ext_api_github_repo }}).

We've also split our environments across two AWS accounts; `Development` and `Production`. In this section, we are going to look at the development workflow for a real world Serverless app.

Here is roughly what we are going to be covering:

- Developing your Lambda functions locally
- Invoking API Gateway endpoints locally
- Creating and working on feature environments
- Creating a pull request environment
- Merging a PR environment to dev
- Promoting dev to production
- Rolling back

Let's start with how you work locally on your Lambda functions.
