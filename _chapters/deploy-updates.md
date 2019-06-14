---
layout: post
title: Deploy Updates
date: 2017-02-12 00:00:00
lang: en
description: Tutorial on how to deploy updates to your React.js single page application hosted on AWS S3 and CloudFront.
comments_id: deploy-updates/16
ref: deploy-updates
---

Now let's look at how we make changes and update our app. The process is very similar to how we deployed our code to S3 but with a few changes. Here is what it looks like.

1. Build our app with the changes
2. Deploy to the main S3 Bucket
3. Invalidate the cache in both our CloudFront Distributions

We need to do the last step since CloudFront caches our objects in its edge locations. So to make sure that our users see the latest version, we need to tell CloudFront to invalidate it's cache in the edge locations.

Let's start by making a couple of changes to our app and go through the process of deploying them.
