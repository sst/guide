---
layout: post
ref: what-does-this-guide-cover
title: What Does This Guide Cover?
date: 2016-12-22 00:00:00
lang: en
ref: what-does-this-guide-cover
context: true
comments_id: what-does-this-guide-cover/83
---

To step through the major concepts involved in building web applications, we are going to be building a simple note taking app called [**Scratch**](https://demo2.serverless-stack.com).

![Completed app desktop screenshot](/assets/completed-app-desktop.png)

<img alt="Completed app mobile screenshot" src="/assets/completed-app-mobile.png" width="432" />

It is a single page application powered by a serverless API written completely in JavaScript. Here is the complete source for the [backend]({{ site.backend_github_repo }}) and the [frontend]({{ site.frontend_github_repo }}). It is a relatively simple application but we are going to address the following requirements.

- Should allow users to signup and login to their accounts
- Users should be able to create notes with some content
- Each note can also have an uploaded file as an attachment
- Allow users to modify their note and the attachment
- Users can also delete their notes
- The app should be able to process credit card payments
- App should be served over HTTPS on a custom domain
- The backend APIs need to be secure
- The app needs to be responsive

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
- [React.js][React] for our single page app
- [React Router][RR] for routing
- [Bootstrap][Bootstrap] for the UI Kit
- [Stripe][Stripe] for processing credit card payments
- [Seed][Seed] for automating Serverless deployments
- [Netlify][Netlify] for automating React deployments
- [GitHub][GitHub] for hosting our project repos.

We are going to be using the **free tiers** for the above services. So you should be able to sign up for them for free. This of course does not apply to purchasing a new domain to host your app. Also for AWS, you are required to put in a credit card while creating an account. So if you happen to be creating resources above and beyond what we cover in this tutorial, you might end up getting charged.

While the list above might look daunting, we are trying to ensure that upon completing the guide you'll be ready to build **real-world**, **secure**, and **fully-functional** web apps. And don't worry we'll be around to help!

### Requirements

You need [Node v8.10+ and NPM v5.5+](https://nodejs.org/en/). You also need to have basic knowledge of how to use the command line. 

### How This Guide Is Structured

The guide is split into two separate parts. They are both relatively standalone. The first part covers the basics while the second covers a couple of advanced topics along with a way to automate the setup. We launched this guide in early 2017 with just the first part. The Serverless Stack community has grown and many of our readers have used the setup described in this guide to build apps that power their businesses.

So we decided to extend the guide and add a second part to it. This is targeting folks that are intending to use this setup for their projects. It automates all the manual steps from part 1 and helps you create a production ready workflow that you can use for all your serverless projects. Here is what we cover in the two parts.

#### Part I

Create the notes application and deploy it. We cover all the basics. Each service is created by hand. Here is what is covered in order.

For the backend:

- Configure your AWS account
- Create your database using DynamoDB
- Set up S3 for file uploads
- Set up Cognito User Pools to manage user accounts
- Set up Cognito Identity Pool to secure our file uploads
- Set up the Serverless Framework to work with Lambda & API Gateway
- Write the various backend APIs

For the frontend:

- Set up our project with Create React App
- Add favicons, fonts, and a UI Kit using Bootstrap
- Set up routes using React-Router
- Use AWS Cognito SDK to login and signup users
- Plugin to the backend APIs to manage our notes
- Use the AWS JS SDK to upload files 
- Create an S3 bucket to upload our app
- Configure CloudFront to serve out our app
- Point our domain with Route 53 to CloudFront
- Set up SSL to serve our app over HTTPS

#### Part II

Aimed at folks who are looking to use the Serverless Stack for their day-to-day projects. We automate all the steps from the first part. Here is what is covered in order.

For the backend:

- Configure DynamoDB through code
- Configure S3 through code
- Configure Cognito User Pool through code
- Configure Cognito Identity Pool through code
- Environment variables in Serverless Framework
- Working with the Stripe API
- Working with secrets in Serverless Framework
- Unit tests in Serverless
- Automating deployments using Seed
- Configuring custom domains through Seed
- Monitoring deployments through Seed

For the frontend

- Environments in Create React App
- Accepting credit card payments in React
- Automating deployments using Netlify
- Configure custom domains through Netlify

We think this will give you a good foundation on building full-stack production ready serverless applications. If there are any other concepts or technologies you'd like us to cover, feel free to let us know on our [forums]({{ site.forum_url }}).


[Cognito]: https://aws.amazon.com/cognito/
[CM]: https://aws.amazon.com/certificate-manager
[R53]: https://aws.amazon.com/route53/
[CF]: https://aws.amazon.com/cloudfront/
[S3]: https://aws.amazon.com/s3/
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
