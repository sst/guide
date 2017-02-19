---
layout: post
title: What are we building?
---

To step through the major concepts involved in building web applications, we are going to be building a simple note taking app called [Scratch](https://demo.serverless-stack.com). It is a single page application powered by a serverless API. And we'll be using the AWS Platform to build it. We might expand further and cover a few other platforms but we figured the AWS Platform would be a good place to start. We'll be using the following set of technologies to build our serverless application. 

- [Lambda](Lambda) & [API Gateway](APIG) for our serverless API.
- [DynamoDB](DynamoDB) for our database.
- [Cognito](Cognito) for user authentication and securing our APIs.
- [React.js](React) for our single page app.
- [React Router](RR) for routing.
- [Bootstrap](Bootstrap) for our UI Kit.
- [S3](S3) for hosting our app and file uploads.
- [CloudFront](CF) for serving out our app.
- [Route 53](R53) for our domain.
- [Certificate Manager](CM) for SSL.

While the list above might look daunting, we are trying to ensure that upon completing the guide you'll be ready to build a full functional web app. There are a few web development concepts that we'll be covering along the way.

- User Authentication
- Creating CRUD APIs
- Plugging into a database
- Handling user sessions
- Routing
- Uploading files

We think this will give you a good foundation on building serverless applications. If there are any other concepts or technologies you'd like us to cover, feel free to let us know via [email](contact@anoma.ly) or by opening a [new issue](https://github.com/AnomalyInnovations/serverless-stack-com/issues/new).



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
