---
layout: post
title: Creating a CI/CD pipeline for React
date: 2020-11-04 00:00:00
lang: en
description: 
ref: creating-a-ci-cd-pipeline-for-react
redirect_from: /chapters/automating-react-deployments.html
comments_id: 
---

Now that we have our backend deployments automated, we are ready to do the same for our frontend React app. Just like the [backend CI/CD pipeline]({% link _chapters/creating-a-ci-cd-pipeline-for-serverless.md %}), we can use something like [Travis CI](https://travis-ci.org) or [CircleCI](https://circleci.com). But these take a lot of scripts and configuration to set up.

Thankfully [Netlify](https://www.netlify.com), the service that we are using to [host our React app]({% link _chapters/hosting-your-react-app.md %}), also supports CI/CD.

Here is the CI/CD pipeline that we are trying to create for our React app.

![React CI/CD pipeline](/assets/diagrams/react-ci-cd-pipeline.png)

Here is what our workflow is going to look like:

- Our repo will be connected to our CI/CD service.
- Any commits that are pushed to the `master` branch will be automatically tested, built, and deployed under our production url.
- While any other commits that are pushed to a non-master branch, will be tested, built, and deployed to a unique development url.

There are a couple of differences between our backend workflow and frontend workflow. When we merge our changes and push to master, they are automatically deployed under our production url. We are not using a manual approval step because our React app is a simple static site and even if we make any mistakes there is no chance of a data loss.

Now before we can automate our deployments, we'll need to configure environments in our React app. This'll allow the production version of our React app to connect to our production backend.
