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

Now that we have our backend deployed to production, we are ready to deploy our frotend to production as well! We'll be using a service called [Netlify](https://www.netlify.com) to do this. Netlify will not only host our React app, it'll also help automate our deployments. It's a little like what we did for our serverless API backend. We'll configure it so that it'll deploy our React app when we push our changes to Git. However, there are a couple of subtle differences between the way we configure our backend and frontend deployments.

1. Netlify hosts the React app on their infrastructure. In the case of our serverless API backend, it was hosted on our AWS account.

2. Any changes that are pushed to our `master` branch will update the production version of our React app. This means that we'll need to use a slightly different workflow than our backend. We'll use a separate branch where we will do most of our development and only push to master once we are ready to update production.

We have an alternative version of this where we deploy our React app to S3 and we use CloudFront as a CDN in front of it. Then we used Route 53 to configure our domain with it. We also had to configure the www version of our domain and this needed another S3 and CloudFront distribution. This process can be a bit cumbersome. But if you are looking for a way to deploy and host the React app in your AWS account, we have an Extra Credit chapter on this here — [Deploying a React app on AWS]({% link _chapters/deploying-a-react-app-to-aws.md %}).

Just as in the case with our backend, we could use [Travis CI](https://travis-ci.org) or [Circle CI](https://circleci.com) for this but it can take a bit more configuration and we'll cover that in a different chapter.

Now before we can automate our deployments, we'll need to configure environments in our React app. This'll allow the production version of our React app to connect to our production backend.
