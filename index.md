---
layout: home
description: Free step-by-step tutorials for creating full-stack serverless applications. Learn to build a CRUD app using React.js, AWS Lambda, API Gateway, DynamoDB, and Cognito.
---

{% include lander.html %}

{: .toc }
## Table of Contents

### Introduction

- [Who is this guide for?]({% link _chapters/who-is-this-guide-for.md %})
- [What does this guide cover?]({% link _chapters/what-does-this-guide-cover.md %})
- [How to get help?]({% link _chapters/how-to-get-help.md %})
- [Why create serverless apps?]({% link _chapters/why-create-serverless-apps.md %})

### Set up your AWS account

- [Create an AWS account]({% link _chapters/create-an-aws-account.md %})
- [Create an IAM user]({% link _chapters/create-an-iam-user.md %})
  - [What is IAM]({% link _chapters/what-is-iam.md %})
  - [What is an ARN]({% link _chapters/what-is-an-arn.md %})
- [Configure the AWS CLI]({% link _chapters/configure-the-aws-cli.md %})

### Setting up the Backend

- [Create a DynamoDB table]({% link _chapters/create-a-dynamodb-table.md %})
- [Create an S3 bucket for file uploads]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %})
- [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %})
  - [Create a Cognito test user]({% link _chapters/create-a-cognito-test-user.md %})
- [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %})
  - [Cognito user pool vs identity pool]({% link _chapters/cognito-user-pool-vs-identity-pool.md %})
- [Set up the Serverless Framework]({% link _chapters/setup-the-serverless-framework.md %})
  - [Add support for ES6/ES7 JavaScript]({% link _chapters/add-support-for-es6-es7-javascript.md %})

### Building the Backend

- [Add a create note API]({% link _chapters/add-a-create-note-api.md %})
- [Add a get note API]({% link _chapters/add-a-get-note-api.md %})
- [Add a list all the notes API]({% link _chapters/add-a-list-all-the-notes-api.md %})
- [Add an update note API]({% link _chapters/add-an-update-note-api.md %})
- [Add a delete note API]({% link _chapters/add-a-delete-note-api.md %})

### Deploying the Backend

- [Deploy the APIs]({% link _chapters/deploy-the-apis.md %})

### Setting up the Frontend

- [Create a new React.js app]({% link _chapters/create-a-new-reactjs-app.md %})
  - [Add app favicons]({% link _chapters/add-app-favicons.md %})
  - [Set up custom fonts]({% link _chapters/setup-custom-fonts.md %})
  - [Set up Bootstrap]({% link _chapters/setup-bootstrap.md %})
- [Handle routes with React Router]({% link _chapters/handle-routes-with-react-router.md %})
  - [Create containers]({% link _chapters/create-containers.md %})
  - [Adding links in the navbar]({% link _chapters/adding-links-in-the-navbar.md %})
  - [Handle 404s]({% link _chapters/handle-404s.md %})

### Building the Frontend

- [Create a login page]({% link _chapters/create-a-login-page.md %})
  - [Login with AWS Cognito]({% link _chapters/login-with-aws-cognito.md %})
  - [Add the user token to the state]({% link _chapters/add-the-user-token-to-the-state.md %})
  - [Load the state from the session]({% link _chapters/load-the-state-from-the-session.md %})
  - [Clear the session on logout]({% link _chapters/clear-the-session-on-logout.md %})
  - [Redirect on login and logout]({% link _chapters/redirect-on-login-and-logout.md %})
  - [Give feedback while logging in]({% link _chapters/give-feedback-while-logging-in.md %})
- [Create a signup page]({% link _chapters/create-a-signup-page.md %})
  - [Create the signup form]({% link _chapters/create-the-signup-form.md %})
  - [Signup with AWS Cognito]({% link _chapters/signup-with-aws-cognito.md %})
- [Add the create note page]({% link _chapters/add-the-create-note-page.md %})
  - [Call the create API]({% link _chapters/call-the-create-api.md %})
  - [Upload a file to S3]({% link _chapters/upload-a-file-to-s3.md %})
  - [Clear AWS Credentials Cache]({% link _chapters/clear-aws-credentials-cache.md %})
- [List all the notes]({% link _chapters/list-all-the-notes.md %})
  - [Call the list API]({% link _chapters/call-the-list-api.md %})
- [Display a note]({% link _chapters/display-a-note.md %})
  - [Render the note form]({% link _chapters/render-the-note-form.md %})
  - [Save changes to a note]({% link _chapters/save-changes-to-a-note.md %})
  - [Delete a note]({% link _chapters/delete-a-note.md %})
- [Set up secure pages]({% link _chapters/setup-secure-pages.md %})
  - [Create a route that redirects]({% link _chapters/create-a-route-that-redirects.md %})
  - [Use the redirect routes]({% link _chapters/use-the-redirect-routes.md %})
  - [Redirect on login]({% link _chapters/redirect-on-login.md %})

### Deploying the Frontend

- [Deploy the Frontend]({% link _chapters/deploy-the-frontend.md %})
  - [Create an S3 bucket]({% link _chapters/create-an-s3-bucket.md %})
  - [Deploy to S3]({% link _chapters/deploy-to-s3.md %})
  - [Create a CloudFront distribution]({% link _chapters/create-a-cloudfront-distribution.md %})
  - [Set up your domain with CloudFront]({% link _chapters/setup-your-domain-with-cloudfront.md %})
  - [Set up www domain redirect]({% link _chapters/setup-www-domain-redirect.md %})
  - [Set up SSL]({% link _chapters/setup-ssl.md %})
- [Deploy updates]({% link _chapters/deploy-updates.md %})
  - [Update the app]({% link _chapters/update-the-app.md %})
  - [Deploy again]({% link _chapters/deploy-again.md %})

### Conclusion

- [Wrapping up]({% link _chapters/wrapping-up.md %})

<hr class="tools" />

### Tools

- [Serverless ES7 Service]({% link _chapters/serverless-es7-service.md %})

{% include share-index.html %}
