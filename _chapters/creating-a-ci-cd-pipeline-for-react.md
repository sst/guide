---
layout: post
title: Creating a CI/CD pipeline for React
date: 2020-11-04 00:00:00
lang: en
description: In this chapter we are going to look at how to create a CI/CD pipeline for our React app. We'll be using a service called Netlify for this. And we'll be using a branch based Git workflow.
ref: creating-a-ci-cd-pipeline-for-react
redirect_from: /chapters/automating-react-deployments.html
comments_id: creating-a-ci-cd-pipeline-for-react/188
---

Now that we have our backend deployments automated, we are ready to do the same for our frontend React app. Just like the [backend CI/CD pipeline]({% link _chapters/creating-a-ci-cd-pipeline-for-serverless.md %}), we can use something like [Travis CI](https://travis-ci.org) or [CircleCI](https://circleci.com). But these take a lot of scripts and configuration to set up.

Thankfully [Netlify](https://www.netlify.com), the service that we are using to [host our React app]({% link _chapters/hosting-your-react-app.md %}), also supports CI/CD.

Here's what the CI/CD pipeline for our React app will look like.

![React CI/CD pipeline](/assets/diagrams/react-ci-cd-pipeline.png)

Let's go over the workflow.

- Our repo will be connected to our CI/CD service.
- Any commits that are pushed to the `master` branch will be automatically built and deployed under our production url.
- While any other commits that are pushed to a non-master branch, will be built and deployed to a unique development url.

There are a couple of differences between [our backend workflow]({% link _chapters/creating-a-ci-cd-pipeline-for-serverless.md %}) and frontend workflow. When we merge our changes and push to master, they are automatically deployed under our production url. We are not using a manual approval step because our React app is a simple static site. So even if we make any mistakes there's no chance of a data loss.

The one thing we haven't done for our React app is set up environments. We want our development branches to connect to our development backend resources. And likewise for our production branch. We'll need to do this before we can automate our deployments.

So let's do that next!
