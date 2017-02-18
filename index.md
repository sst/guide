---
layout: home
---

Serverless Stack is a comprehensive step-by-step guide for creating full-stack serverless applications. We'll be creating a [simple note taking app](https://demo.serverless-stack.com) from scratch using React.js, AWS Lambda, and a few other AWS services.

### Introduction

- [Who is this for?]({% link _chapters/who-is-this-for.md %})
- [What are we building?]({% link _chapters/what-are-we-building.md %})
- [How to get help?]({% link _chapters/how-to-get-help.md %})
- [Why create serverless apps?]({% link _chapters/why-create-serverless-apps.md %})

### Setting up the Backend

- [Create an IAM user]({% link _chapters/create-an-iam-user.md %})
- [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %})
- [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %})
- [Create a DynamoDB table]({% link _chapters/create-a-dynamodb-table.md %})
- [Create Serverless APIs with Lambda]({% link _chapters/create-serverless-apis-with-lambda.md %})

### Setting up the Frontend

- [Create a new app with Create React App]({% link _chapters/create-new-create-react-app.md %})
  - [Add app favicons]({% link _chapters/add-app-favicons.md %})
  - [Using custom fonts]({% link _chapters/using-custom-fonts.md %})
  - [Setting up Bootstrap]({% link _chapters/setting-up-bootstrap.md %})
- [Handle routes with React Router]({% link _chapters/handle-routes-with-react-router.md %})
  - [Create containers]({% link _chapters/create-containers.md %})
  - [Handle 404s]({% link _chapters/handle-404s.md %})

### Building the Frontend

- [Create a login page]({% link _chapters/create-a-login-page.md %})
  - [Login with AWS Cognito]({% link _chapters/login-with-aws-cognito.md %})
  - [Add the user token to the state]({% link _chapters/add-the-user-token-to-the-state.md %})
  - [Load the state from the session]({% link _chapters/load-the-state-from-the-session.md %})
  - [Clear the session on logout]({% link _chapters/clear-the-session-on-logout.md %})
  - [Redirect on login and logout]({% link _chapters/redirect-on-login-and-logout.md %})
  - [User feedback while logging in]({% link _chapters/user-feedback-while-logging-in.md %})
- [Create a signup page]({% link _chapters/create-a-signup-page.md %})
  - [Create the signup form]({% link _chapters/create-the-signup-form.md %})
  - [Signup with AWS Cognito]({% link _chapters/signup-with-aws-cognito.md %})
- [Creating a note]({% link _chapters/creating-a-note.md %})
  - [Calling the create API]({% link _chapters/calling-the-create-api.md %})
  - [Upload file to S3]({% link _chapters/upload-file-to-s3.md %})
  - [Clear AWS Credentials Cache]({% link _chapters/clear-aws-credentials-cache.md %})
- [List all the notes]({% link _chapters/list-all-the-notes.md %})
  - [Calling the list API]({% link _chapters/calling-the-list-api.md %})
- [Display a note]({% link _chapters/display-a-note.md %})
  - [Render the note form]({% link _chapters/render-the-note-form.md %})
  - [Save changes to a note]({% link _chapters/save-changes-to-a-note.md %})
  - [Deleting a note]({% link _chapters/deleting-a-note.md %})
- [Securing pages]({% link _chapters/securing-pages.md %})
  - [Create a HOC that checks auth]({% link _chapters/create-a-hoc-that-checks-auth.md %})
  - [Use the HOC in the routes]({% link _chapters/use-the-hoc-in-the-routes.md %})
  - [Redirect on login]({% link _chapters/redirect-on-login.md %})

### Deploying the Frontend

- [Deploying]({% link _chapters/deploying.md %})
  - [Create a S3 bucket]({% link _chapters/create-a-s3-bucket.md %})
  - [Configure the AWS CLI]({% link _chapters/configure-the-aws-cli.md %})
  - [Deploy to S3]({% link _chapters/deploy-to-s3.md %})
  - [Create a CloudFront distribution]({% link _chapters/create-a-cloudfront-distribution.md %})
  - [Setup your domain with CloudFront]({% link _chapters/setup-your-domain-with-cloudfront.md %})
  - [Setup www domain redirect]({% link _chapters/setup-www-domain-redirect.md %})
  - [Setup SSL]({% link _chapters/setup-ssl.md %})
- [Deploying updates]({% link _chapters/deploying-updates.md %})
  - [Update the app]({% link _chapters/update-the-app.md %})
  - [Deploy again]({% link _chapters/deploy-again.md %})

### Conclusion

- Wrapping up
