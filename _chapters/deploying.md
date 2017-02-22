---
layout: post
title: Deploying
date: 2017-02-05 00:00:00
---

Now that we have our setup working in our local environment, let's do our first deploy and look into what we need to do to host our serverless application.

The basic setup we are using is as follows:

1. Upload our the assets of our app
2. Use a CDN to serve out our assets
3. Point our domain to the CDN distribution
4. Switch to HTTPS using a SSL certificate

AWS provides quite a few services that can help us do the above. We are going to use [S3](https://aws.amazon.com/s3/) to host our assets, [CloudFront](https://aws.amazon.com/cloudfront/) to serve it, [Route 53](https://aws.amazon.com/route53/) to manage our domain, and [Certificate Manager](https://aws.amazon.com/certificate-manager/) to handle our SSL certificate.

So let's get started by first configuring our S3 bucket to upload the assets for our app.
