---
layout: post
title: Deploying a React App to Netlify
date: 2020-11-03 00:00:00
lang: en
description: In this chapter we'll be looking at hosting your React app on Netlify. Our React app is a static site and it's pretty simple to host them.
redirect_from: /chapters/hosting-your-react-app.html
ref: deploying-a-react-app-to-netlify
comments_id: hosting-your-react-app/2177
---

In this section we'll be looking at how to deploy your React.js app as a static website to [Netlify](https://www.netlify.com). You'll recall that in the [main part of the guide]({% link _chapters/create-a-new-reactjs-app.md %}) we used the SST [`ReactStaticSite`](https://docs.serverless-stack.com/constructs/ReactStaticSite) construct to deploy our React app to AWS.

Netlify allows you to [host your React app for free](https://www.netlify.com/pricing/) and it allows your to `git push` to deploy your apps.

The basic setup we are going to be using will look something like this:

1. Setup our project on Netlify
2. Configure custom domains
3. Create a CI/CD pipeline for our app

We also have another alternative version of this where we deploy our React app to S3 and we use CloudFront as a CDN in front of it. We use Route 53 to configure our custom domain. We also need to configure the www version of our domain and this needs another S3 and CloudFront distribution. The entire process can be a bit cumbersome. But if you are looking for a way to deploy and host the React app in your AWS account, we have an Extra Credit chapter on this — [Deploying a React app on AWS]({% link _chapters/deploying-a-react-app-to-aws.md %}).

Let's get started by creating our project on Netlify.
