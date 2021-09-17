---
layout: post
title: Using Facebook to add authentication to a serverless app
date: 2021-09-14 00:00:00
lang: en
description: 
ref: using-facebook-to-add-authentication-to-a-serverless-app
comments_id: 
---

To integrate Facebook social authentication into your [AWS serverless](https://aws.amazon.com/serverless/) API and your [React](https://reactjs.org) application, here is what you’ll need: 

* [Node.js](https://nodejs.org)
* An [AWS account](https://serverless-stack.com/chapters/create-an-aws-account.html) with [AWS CLI configured](https://serverless-stack.com/chapters/configure-the-aws-cli.html)
* A [Facebook developer account](https://developers.facebook.com/)

But why Facebook, you ask? According to data from [Statista](https://www.statista.com/statistics/264810/number-of-monthly-active-facebook-users-worldwide/), in the first quarter of 2021, the number of Facebook users climbed to 2.8 billion. There is a high chance that your prospective user has a Facebook account, so you’ll be making it easy for them to use your product without filling out boring forms or forcing them to remember their passwords on multiple websites.

Let’s get started with adding Facebook authentication to your serverless backend. First, you’ll need to create a Facebook app in order to get the necessary credentials to develop on the Facebook platform.

## Creating a Facebook App

Go to [Facebook for Developers](https://developers.facebook.com/) and click **My Apps > Create App**.

![Create App](https://i.imgur.com/9v8AnNt.png)

In the pop-up, select the **Consumer** app type.

![Connect Consumer](https://i.imgur.com/4n5Yeq6.png)

You’ll be asked to fill in the app details.

![Facebook app creation form](https://i.imgur.com/i89OLa4.png)

Select the type of application you want to integrate with.

![Facebook App Platforms](https://i.imgur.com/0T9xDjx.png)

And finally, set up Facebook Login.

![Facebook Login setup](https://i.imgur.com/NWg0yKx.png)

After that, you can copy your `AppID` as shown below:

![Facebook App ID](https://i.imgur.com/Q3S3gdC.png)

You’ll find some sample integration code after completing the process, but you’ll use that in the frontend.

Your Facebook ID is required to integrate Facebook auth into your application. Now that you have it, you can set up your [SST](https://serverless-stack.com) backend.

Run the following command on your terminal to install SST:

``` bash
npx create-serverless-stack@latest fb-auth

cd fb-auth
```

In the boilerplate code generated, you’ll see a couple of files. However, we’ll focus on the `lib/MyStack.js` file. It should look like this:

``` js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
 constructor(scope, id, props) {
   super(scope, id, props);

   // Create a HTTP API
   const api = new sst.Api(this, "Api", {
     routes: {
       "GET /": "src/lambda.handler",
     },
   });

   // Show the endpoint in the output
   this.addOutputs({
     "ApiEndpoint": api.url,
   });
 }
}
```

To create the Facebook auth, add the [Auth](https://docs.serverless-stack.com/constructs/Auth#facebook) construct as shown below:

``` js
   const auth = new sst.Auth(this, "Auth", {
         facebook: { appId: "5037056767799" }
   });
```

Remember the Facebook `appID` you got from setting up the Facebook app? Now is when you need it. Replace yours in the `facebook` object above.

Add a secure API endpoint with the [Api](https://docs.serverless-stack.com/constructs/Api) construct:

``` js
   // Create a HTTP API
   const api = new sst.Api(this, "Api", {
     defaultAuthorizationType: sst.ApiAuthorizationType.AWS_IAM,
     routes: {
       "GET /private": "src/private.handler"
     }
   });
```

Finally, return the outputs and attach the permission to the API, as shown below:

``` js
   // Show the endpoint in the output
   this.addOutputs({
     ApiEndpoint: api.url,
     IdentityPoolId: auth.cognitoCfnIdentityPool.ref,
   });

   // Allow auth users to access the API
   auth.attachPermissionsForAuthUsers([api]);
```

You’ll need to add the Lambda function you want to execute when this route is called.

Create the function in `src/private.js` and insert the default `hello world` code. If the user logs in successfully, they should see the Hello World! message.

``` js
export async function handler(event) {
 return {
   statusCode: 200,
   headers: { "Content-Type": "text/plain" },
   body: `Hello, World! Your request was received at ${event.requestContext.time}.`,
 };
}
```

That’s it. Now, deploy the application to AWS using SST.

Run `npx sst start`. This should set up everything on AWS for you, and the result should look like this:

``` bash

dev-facebook-auth-my-stack | UPDATE_IN_PROGRESS | AWS::CloudFormation::Stack | dev-facebook-auth-my-stack 
dev-facebook-auth-my-stack | UPDATE_IN_PROGRESS | AWS::Cognito::IdentityPool | AuthIdentityPool1ghfjhB5E1 
dev-facebook-auth-my-stack | UPDATE_IN_PROGRESS | AWS::CDK::Metadata | CDKMetadata 
dev-facebook-auth-my-stack | UPDATE_COMPLETE | AWS::Cognito::IdentityPool | AuthIdentityPool12DFB5E1 
dev-facebook-auth-my-stack | UPDATE_COMPLETE | AWS::CDK::Metadata | CDKMetadata 
dev-facebook-auth-my-stack | UPDATE_COMPLETE_CLEANUP_IN_PROGRESS | AWS::CloudFormation::Stack | dev-facebook-auth-my-stack 
dev-facebook-auth-my-stack | UPDATE_COMPLETE | AWS::CloudFormation::Stack | dev-facebook-auth-my-stack 

 ✅ dev-facebook-auth-my-stack


Stack dev-facebook-auth-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://h7h456b839.execute-api.us-east-1.amazonaws.com
    IdentityPoolId: us-east-1:16f3ffbb-6b76-4b9c-b083-tgj-5e43404b7t
```

Your API is set.

## Set up Frontend with React and Amplify

Now set up the frontend with [React](https://reactjs.org/). Install React with [Create-React-App](https://create-react-app.com) by running 

``` bash
npx reate-react-app my-app
```

Once the download is complete, [set up Amplify](https://serverless-stack.com/chapters/configure-aws-amplify.html) to work with your React application.

Run the following commands to install the required dependencies.

``` bash
npm install aws-amplify aws-amplify-react
```

Then initialize Amplify in your project by running `amplify init`. You’ll be prompted to respond to a few questions on the command line as shown below:

![Sample commands](https://i.imgur.com/wArrMWs.png)

Once that setup is complete, run `amplify add auth` to add authentication setup to the application. Choose `Default configuration with Social Provider (Federation)`.

![Auth setup](https://i.imgur.com/Ww4rLby.png)

Finish the setup and choose Facebook as the authentication provider. Amplify will configure Facebook authentication for your application. 

Run `amplify push` to push the application to AWS.

It might take a while but once it completes, two links will be generated for you as shown below:

![Amplify push result](https://i.imgur.com/attwuzc.png)

You’ll need the link that reads *Hosted UI Endpoint*. It will become your platform URL on the Facebook developer sandbox. You can also find this URL in the `aws-exports.json` file.

Now head back to the [Facebook sandbox](https://developers.facebook.com/) to complete the setup process.

Append `/oauth2/idpresponse` to the hosted endpoint you copied earlier and save it as the redirect URI. It should look like this image:

![OAuth redirect URI](https://i.imgur.com/ZiWcJNU.png)

Now go to **Settings** and copy out your private key and App ID. You’ll use them in the next steps to configure AWS Cognito user pool.

![App settings](https://i.imgur.com/tAbitEL.png)

Next, configure your AWS user pool to support Facebook Federated authentication.

Run `amplify console auth`. Select the **User Pool** option to go to the AWS console. Navigate to **Federation > Identity Providers**, select **Facebook**, and enter your App ID and Secret as shown below:

![Facebook Secrets on AWS Console](https://i.imgur.com/Vml5eg5.png)

Now all configurations are completed.

Go to your React app. Add Amplify configuration by importing the `aws-exports.json` file and pass it to the `Amplify.config` function in the `index.js` file.

``` js
...
import awsexports from './aws-exports';
import Amplify from 'aws-amplify';
Amplify.configure(awsexports) 

ReactDOM.render(
 <React.StrictMode>
   <App />
 </React.StrictMode>,
 document.getElementById('root')
);
```

In the `App.js` file, import the Auth construct and add an onClick function with federated user `Auth.federatedSignIn`, as shown in the code below:

``` js
import './App.css';
import { Auth } from "aws-amplify";
import { Button, Col, Row, Container } from 'react-bootstrap';

const App = () => {
   return (
       <>
<Container>
 <Row style={{ padding:"50px"}}>
       <Col><Button onClick={()=> Auth.federatedSignIn()}> Sign In </Button></Col>
 </Row>
</Container>
     </>

   );
}

export default App;
```

Run your React app with `npm start` on the terminal. When the page loads, click the **sign-in** button. You should see the Hosted UI, as shown below.

![Login screen](https://i.imgur.com/A93YYY2.png)

Click **Continue with Facebook**, and you will be prompted to grant the app permissions, after which you’ll be logged in successfully. An `access_code` will be returned and the user will be authenticated.

## Connecting to the Lambda API

To connect to the Lambda API from React, you’ll need to add the API configuration in the `aws-exports.json` file like this:

``` js

 "API": {
       "endpoints": [
           {
               "name": "hello",
               "endpoint": "https://w079dsaapx97l2.execute-api.us-east-1.amazonaws.com",
               "service": "lambda",
               "region": "us-east-1"
           }
       ]
   },
```

The `endpoint` is the `ApiEndpoint` you get when you run `npx sst start` on your AWS API.

The full `aws-exports.json` file should now be updated, and it should look like this:

``` js
const awsmobile = {
   "aws_project_region": "us-east-1",
   "aws_cognito_identity_pool_id": "us-east-1:04a0ds44-8017-4d88-a563-080affdgdd2d38",
   "aws_cognito_region": "us-east-1",
   "aws_user_pools_id": "us-east-1_dhen52ZSw",
   "aws_user_pools_web_client_id": "261oissqotkglra9vresfsci78qim",
   "API": {
       "endpoints": [
           {
               "name": "private",
               "endpoint": "https://w079dsaapx97l2.execute-api.us-east-1.amazonaws.com",
               "service": "lambda",
               "region": "us-east-1"
           }
       ]
   },
   "oauth": {
       "domain": "domain-dev.auth.us-east-1.amazoncognito.com",
       "scope": [
           "phone",
           "email",
           "openid",
           "profile",
           "aws.cognito.signin.user.admin"
       ],
       "redirectSignIn": "http://localhost:3000/",
       "redirectSignOut": "http://localhost:3000/",
       "responseType": "code"
   },
   "federationTarget": "COGNITO_USER_POOLS"
};

export default awsmobile;
```

## Make the API Call

To make the API call after the user has logged in successfully, create a `privateComponent` component. In this component, you’ll get the user’s token from `Auth.currentSession()` and use it to make an API call to the Lambda API, as shown below:

``` js
import { useEffect, useState } from "react";
import { Auth, API } from "aws-amplify";


const PrivateComponent = () => {
   const [isLoggedIn, setIsLoggedIn] = useState(false)
   const [credential, setCredential] = useState("")
   const [Result, setResult] = useState("");

   useEffect(() => {
       Auth.currentSession().then(async (data) => {
           let token = (await Auth
               .currentSession())
               .getIdToken()
               .getJwtToken();
              
           setCredential(token);
       }
       )
   }, []);


   if (isLoggedIn) {
       API.get("private", "/private", {
           headers: {
               Authorization: `Bearer ${credential}`
           }
       }).then((result) => {
           setResult(result)
           setIsLoggedIn(true)
       }).catch((error) => {
           console.log(error.message)
       })
   }


   return (
       <div className="App">
           {isLoggedIn & <p> Hi, You are logged in. </p> || <p> You are not logged in</p>}
       </div>
   );

};

export default PrivateComponent;

```

That’s it. You can now make calls to the API after authentication with Facebook. 

You can find the sample code for the frontend in [this repository](https://github.com/ezesundayeze/fb-aws-sst) and the backend in [this repository](https://github.com/ezesundayeze/fb-sst-backend) on GitHub.
