---
layout: post
title: Working on Serverless Apps
description: In this section of the guide we look at the development workflow of a real world Serverless app.
date: 2019-10-07 00:00:00
comments_id: 
---

So to quickly recap, we've split our real world Serverless app into two repos, [one creates our infrastructure resources]({{ site.backend_ext_resources_github_repo }}) and the [second creates our API services]({{ site.backend_ext_api_github_repo }}).

We've also split our environments across two AWS accounts; `Development` and `Production`. In this section, we are going to look at the development workflow for a real world Serverless app.

Here is roughly what we are going to be covering:

- [Developing your Lambda functions locally]({% link _chapters/invoke-lambda-functions-locally.md %})
- [Invoking API Gateway endpoints locally]({% link _chapters/invoke-api-gateway-endpoints-locally.md %})
- [Creating and working on feature environments]({% link _chapters/creating-feature-environments.md %})
- [Creating a pull request environment]({% link _chapters/creating-pull-request-environments.md %})
- [Promoting dev to production]({% link _chapters/promoting-to-production.md %})
- [Rolling back]({% link _chapters/rollback-changes.md %})

Let's start with how you work locally on your Lambda functions.
