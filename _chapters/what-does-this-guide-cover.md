---
layout: post
ref: what-does-this-guide-cover
title: What Does This Guide Cover?
date: 2016-12-22 00:00:00
lang: en
ref: what-does-this-guide-cover
comments_id: what-does-this-guide-cover/83
---

To step through the major concepts involved in building web applications, we are going to be building a simple note taking app called [**Scratch**]({{ site.demo_url }}).

However, unlike most tutorials out there, our goal is to go into the details of what it takes to build a full-stack application for production.

### Demo App

The demo app is a single page application powered by a serverless API written completely in JavaScript.

[![Completed app desktop screenshot](/assets/completed-app-desktop.png)]({{ site.demo_url }})

![Completed app mobile screenshot](/assets/completed-app-mobile.png){: width="432" }

It is a relatively simple application but we are going to address the following requirements.

- Should allow users to signup and login to their accounts
- Users should be able to create notes with some content
- Each note can also have an uploaded file as an attachment
- Allow users to modify their note and the attachment
- Users can also delete their notes
- The app should be able to process credit card payments
- App should be served over HTTPS on a custom domain
- The backend APIs need to be secure
- The app needs to be responsive
- The app should be deployed when we `git push`
- We should be able to monitor and debug any errors

#### Demo Source

Here is the complete source of the app we'll be building. We recommend bookmarking it and use it as a reference.

- [**Demo source**]({{ site.sst_demo_repo }})

We'll be using the AWS Platform to build it. We might expand further and cover a few other platforms but we figured the AWS Platform would be a good place to start.

### Technologies & Services

We'll be using the following set of technologies and services to build our serverless application. 

- [Lambda][Lambda] & [API Gateway][APIG] for our serverless API
- [DynamoDB][DynamoDB] for our database
- [Cognito][Cognito] for user authentication and securing our APIs
- [S3][S3] for hosting our app and file uploads
- [CloudFront][CF] for serving out our app
- [Route 53][R53] for our domain
- [Certificate Manager][CM] for SSL
- [CloudWatch][CloudWatch] for Lambda and API access logs
- [React.js][React] for our single page app
- [React Router][RR] for routing
- [Bootstrap][Bootstrap] for the UI Kit
- [Stripe][Stripe] for processing credit card payments
- [Seed][Seed] for automating serverless deployments
- [Netlify][Netlify] for automating React deployments
- [GitHub][GitHub] for hosting our project repos
- [Sentry][Sentry] for error reporting

We are going to be using the **free tiers** for the above services. So you should be able to sign up for them for free. This of course does not apply to purchasing a new domain to host your app. Also for AWS, you are required to put in a credit card while creating an account. So if you happen to be creating resources above and beyond what we cover in this tutorial, you might end up getting charged.

While the list above might look daunting, we are trying to ensure that upon completing the guide you'll be ready to build **real-world**, **secure**, and **fully-functional** web apps. And don't worry we'll be around to help!

### Requirements

You just need a couple of things to work through this guide:

- [Node v12+ and NPM v6+](https://nodejs.org/en/) installed on your machine.
- A free [GitHub account](https://github.com/join).
- And basic knowledge of how to use the command line. 

### How This Guide Is Structured

The guide is split roughly into a couple of parts:

1. **The Basics**

   Here we go over how to create your first full-stack serverless application. These chapters are roughly split up between the backend (Serverless) and the frontend (React). We also talk about how to deploy your serverless app and React app into production.

   This section of the guide is carefully designed to be completed in its entirety. We go into all the steps in detail and have tons of screenshots to help you build your first app.

2. **The Best Practices**

   We launched this guide in early 2017 with just the first part. The SST community has grown and many of our readers have used the setup described in this guide to build apps that power their businesses. In this section, we cover the best practices of running production applications. These really begin to matter once your application codebase grows or when you add more folks to your team.

   The chapters in this section are relatively standalone and tend to revolve around specific topics.

3. **Using Serverless Framework**

   The main part of the guide uses [**SST**]({{ site.sst_github_repo }}). But we also cover building the same app using [Serverless Framework](https://github.com/serverless/serverless). This is an optional section and is meant for folks trying to learn Serverless Framework.

4. **Reference**

   Finally, we have a collection of standalone chapters on various topics. We either refer to these in the guide or we use this to cover topics that don't necessarily belong to either of the two above sections.

#### Building Your First Serverless App

The first part of this guide helps you create the notes application and deploy it to production. We cover all the basics. Each service is created by hand. Here is what is covered in order.

For the backend:

- Configure your AWS account
- Create your database using DynamoDB
- Set up S3 for file uploads
- Write the various backend APIs
- Set up Cognito User Pools to manage user accounts
- Set up Cognito Identity Pool to secure our resources
- Working with secrets
- Adding unit tests

For the frontend:

- Set up our project with Create React App
- Add favicons, fonts, and a UI Kit using Bootstrap
- Set up routes using React Router
- Use AWS Cognito with Amplify to login and signup users
- Plugin to the backend APIs to manage our notes
- Use the AWS Amplify to upload files 
- Accepting credit cards with the Stripe React SDK

Deploying to prod:

- Use custom domains for the API and React
- Create a CI/CD pipeline with Seed

Monitoring and debugging serverless apps:

- Set up error reporting in React using Sentry
- Configure an Error Boundary in React
- Add error logging to our serverless APIs
- Cover the debugging workflow for common serverless errors


We think this will give you a good foundation on building full-stack production ready serverless applications. If there are any other concepts or technologies you'd like us to cover, feel free to let us know on our [forums]({{ site.forum_url }}).

[Cognito]: https://aws.amazon.com/cognito/
[CM]: https://aws.amazon.com/certificate-manager
[R53]: https://aws.amazon.com/route53/
[CF]: https://aws.amazon.com/cloudfront/
[S3]: https://aws.amazon.com/s3/
[CloudWatch]: https://aws.amazon.com/cloudwatch/
[Bootstrap]: http://getbootstrap.com
[RR]: https://github.com/ReactTraining/react-router
[React]: https://facebook.github.io/react/
[DynamoDB]: https://aws.amazon.com/dynamodb/
[APIG]: https://aws.amazon.com/api-gateway/
[Lambda]: https://aws.amazon.com/lambda/
[Stripe]: https://stripe.com
[Seed]: https://seed.run
[Netlify]: https://netlify.com
[GitHub]: https://github.com
[Sentry]: https://sentry.io
