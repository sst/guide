---
layout: post
title: Deploying Updates
---

Now let's look at how we make changes and update our app. The process is very simillar to how we deployed our code to S3 but with a few changes. Here is what it looks like.

1. Build our app with the changes.
2. Deploy to the main S3 Bucket.
3. Invalidate the cache in our CloudFront buckets.

We need to do the last step since CloudFront caches our objects in it's edge locations. So to make sure that our users see the latest version, we need to tell CloudFront to invalidate it's cache in the edge locations.

Let's start by making a couple of changes to our app and go through the process of deploying them.
