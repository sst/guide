---
layout: post
title: Automating React Deployments
date: 2018-03-25 00:00:00
lang: en
description: We want to automatically deploy our Create React App when we push any changes to our Git repository. To do this, we will need to set our project up on Netlify.
context: true
ref: automating-react-deployments
comments_id: automating-react-deployments/188
---

If you've followed along with the first part of this guide, you'll have noticed that we deployed our Create React App to S3 and used CloudFront as a CDN in front of it. Then we used Route 53 to configure our domain with it. We also had to configure the www version of our domain and this needed another S3 and CloudFront distribution. This process can be a bit cumbersome.

In the next few chapters we are going to be using a service called [Netlify](https://www.netlify.com) to automate our deployments. It's a little like what we did for our serverless API backend. We'll configure it so that it'll deploy our React app when we push our changes to Git. However, there are a couple of subtle differences between the way we configure our backend and frontend deployments.

1. Netlify hosts the React app on their infrastructure. In the case of our serverless API backend, it was hosted on our AWS account.

2. Any changes that are pushed to our `master` branch will update the production version of our React app. This means that we'll need to use a slightly different workflow than our backend. We'll use a separate branch where we will do most of our development and only push to master once we are ready to update production.

Just as in the case with our backend, we could use [Travis CI](https://travis-ci.org) or [Circle CI](https://circleci.com) for this but it can take a bit more configuration and we'll cover that in a different chapter.

So let's get started with setting up your project on Netlify.
