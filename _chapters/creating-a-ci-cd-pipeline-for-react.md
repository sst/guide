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

In the last couple of chapters, we [set our React.js app up in Netlify]({% link _chapters/setting-up-your-project-on-netlify.md %}) and [added a custom domain to it]({% link _chapters/custom-domain-in-netlify.md %}). In this chapter we'll look at how to use Netlify to create a CI/CD pipeline for our React app.

Here's what the CI/CD pipeline for our React app will look like.

![React CI/CD pipeline](/assets/diagrams/react-ci-cd-pipeline.png)

Let's go over the workflow.

- Our repo will be connected to our CI/CD service.
- Any commits that are pushed to the `master` branch will be automatically built and deployed under our production url.
- While any other commits that are pushed to a non-master branch, will be built and deployed to a unique development url.

The one thing we haven't talked about for our React app is, environments. We want our development branches to connect to our development backend resources. And likewise for our production branch. We'll need to do this before we can automate our deployments.

So let's do that next!
