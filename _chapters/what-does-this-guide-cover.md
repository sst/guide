---
layout: post
title: What Does This Guide Cover?
date: 2016-12-22 00:00:00
---

To step through the major concepts involved in building web applications, we are going to be building a simple note taking app called [Scratch](https://demo.serverless-stack.com). It is a single page application powered by a serverless API. It is a relatively simple application but it supports the following functionality.

- Needs to be responsive
- Should allow users to signup and login to their accounts
- Needs to have a secure client and API
- Carry out the usual CRUD actions
- Allow users to upload files

We'll be using the AWS Platform to build it. We might expand further and cover a few other platforms but we figured the AWS Platform would be a good place to start. We'll be using the following set of technologies to build our serverless application. 

- [Lambda](Lambda) & [API Gateway](APIG) for our serverless API
- [DynamoDB](DynamoDB) for our database
- [Cognito](Cognito) for user authentication and securing our APIs
- [S3](S3) for hosting our app and file uploads
- [CloudFront](CF) for serving out our app
- [Route 53](R53) for our domain
- [Certificate Manager](CM) for SSL
- [React.js](React) for our single page app
- [React Router](RR) for routing
- [Bootstrap](Bootstrap) for our UI Kit

While the list above might look daunting, we are trying to ensure that upon completing the guide you'll be ready to build **real-world**, **secure**, and **fully-functional** web apps. And don't worry we'll be here to help!

The guide covers the following concepts in order.

For the backend:

- Configure your AWS account
- Create your database using DynamoDB
- Setup S3 for file uploads
- Setup a Cognito User Pools to manage user accounts
- Setup Cognito Identity Pool to secure our file uploads
- Setup the Serverless Framework to work with Lambda & API Gateway
- Write the various backend APIs

For the frontend:

- Setup our project with Create-React-App
- Add favicons, fonts, and a UI Kit using Bootstrap
- Setup routes using React-Router
- Use AWS Cognito SDK to login and signup users
- Plugin to the backend APIs to manage our notes
- Use the AWS JS SDK to upload files 
- Create a S3 bucket to upload our app
- Configure CloudFront to serve out our app
- Point our domain with Route 53 to CloudFront
- Setup SSL to serve our app over HTTPS

We think this will give you a good foundation on building full-stack serverless applications. If there are any other concepts or technologies you'd like us to cover, feel free to let us know via [email](contact@anoma.ly).



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
