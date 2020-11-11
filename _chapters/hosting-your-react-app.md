---
layout: post
title: Hosting Your React App
date: 2020-11-03 00:00:00
lang: en
description: In this chapter we'll be looking at hosting your React app on Netlify. Our React app is a static site and it's pretty simple to host them.
ref: hosting-your-react-app
comments_id: hosting-your-react-app/2177
---

Now that we've completed building our React app, we'll need to host it publicly so anybody can access it. We'll be using a service called [Netlify](https://www.netlify.com) to do this. Netlify will not only host our React app, but a little later in the guide, we'll use it to [automate our deployments as well]({% link _chapters/creating-a-ci-cd-pipeline-for-react.md %}).

It should be noted that there are many options when it comes to hosting your React app. It is a simple static site, as in it's just a bunch of files that are downloaded on to our user's browser. All of our _processing_ is done through our Serverless APIs. This means that it is exceedingly simple to host a React app. They also scale incredibly easily. Meaning that if you notes app goes viral, you won't have to worry about your site being down! It's also really cheap to host them. Netlify [hosts it for free](https://www.netlify.com/pricing/).

We have an alternative version of this where we deploy our React app to S3 and we use CloudFront as a CDN in front of it. We use Route 53 to configure our custom domain. We also need to configure the www version of our domain and this needed another S3 and CloudFront distribution. The entire process can be a bit cumbersome. But if you are looking for a way to deploy and host the React app in your AWS account, we have an Extra Credit chapter on this — [Deploying a React app on AWS]({% link _chapters/deploying-a-react-app-to-aws.md %}).

Let's get started by creating our project on Netlify.
