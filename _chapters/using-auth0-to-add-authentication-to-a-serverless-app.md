---
layout: post
title: Using Auth0 to add authentication to a serverless app
date: 2021-08-05 00:00:00
lang: en
description: 
ref: using-auth0-to-add-authentication-to-a-serverless-app
comments_id: 
---

Requirements
[Node.js](https://nodejs.org)
An [AWS account](https://serverless-stack.com/chapters/create-an-aws-account.html) with [AWS CLI configured](https://serverless-stack.com/chapters/configure-the-aws-cli.html)

[Auth0](https://auth0.io) allows you to integrate authentication into your application easily and for free. And instead of individually implementing multiple social auth providers such as Facebook, Okta, and Twitter, you can use Auth0 and configure it to allow your users to choose their own means of identity authentication. 

## Setting Up SST

AWS can be complex and complicated, but SST was built to make AWS easy and fast. Instead of jumping around your AWS console to find what you need, have SST do the work for you.

Let’s set up SST to work with AWS. Install SST by running the command below:

```ssh
npx create-serverless-stack@latest aws-auth0

cd aws-auth0
```
The installation requires an internet connection to download the boilerplate code, so expect it to take a few minutes depending on your internet speed.

After the installation, you’ll notice an `sst.json file` that defines the environment it will be deployed in. It looks like this:


```json
{
 "name": "my-sst-app",
 "stage": "dev",
 "region": "us-east-1",
 "lint": true
}
```
There are two primary directories that we’ll be working with:`lib/` and `src/`. The `lib/` directory holds data about our stack and more environment configuration. For example, the `lib/index.js` file contains coding as shown below:

```js
import MyStack from "./MyStack";

export default function main(app) {
 // Set default runtime for all functions
 app.setDefaultFunctionProps({
   runtime: "nodejs12.x"
 });

 new MyStack(app, "my-stack");

 // Add more stacks
}
```

This file has been preconfigured with one stack, so unless you want to add more stacks, you won’t need to change this file.

Open the `lib/MyStack.js` file and update its content with the following:

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
 constructor(scope, id, props) {
   super(scope, id, props);

   // Create a HTTP API
   const api = new sst.Api(this, "Api", {
     defaultAuthorizationType: sst.ApiAuthorizationType.AWS_IAM,
    
     routes: {
       "GET /private": "src/lambda.handler",
     },

   });

   const auth = new sst.Auth(this, "Auth", {
     auth0: {
       domain: "dev-8wt5p93b.us.auth0.com",
       clientId: "2Ew7slhEmNyKEzHPJ4Et2iEJapw7dIry",
     }
   });
  
   // Show the endpoint in the output
   this.addOutputs({
     ApiEndpoint: api.url,
     IdentityPoolId: auth.cognitoCfnIdentityPool.ref,
   });

   // Allow authenticated users to invoke the API
   auth.attachPermissionsForAuthUsers([api]);
 }
}
```

Here’s what we’re doing in the code above:
 
1. We are setting the default authorization type to use the AWS IAM user `defaultAuthorizationType: sst.ApiAuthorizationType.AWS_IAM`

2. Then we are creating a route:
  
```js 
     routes: {
       "GET /private": "src/lambda.handler",
     },
 ```

3. We are configuring the `Auth0` auth provider here:

```js
     auth0: {
       domain: "dev-8wt5p93b.us.auth0.com",
       clientId: "2Ew7slhEmNyKEzHPJ4Et2iEJapw7dIry",
     }
```

To get your Auth0 provider client information you’ll need to register on the [Auth0 website](https://auth0.com), create an application, and navigate to your dashboard to get your client ID and auto-generated domain.

4. We are also exposing the API route and the identity pool ID and finally attaching the permission for authenticated users to the API.

```js
   // Show the endpoint in the output
   this.addOutputs({
     ApiEndpoint: api.url,
     IdentityPoolId: auth.cognitoCfnIdentityPool.ref,
   });

   // Allow authenticated users to invoke the API
   auth.attachPermissionsForAuthUsers([api]);
```

Finally, at the backend, we need to write the function that will be triggered when the API is invoked.

```js
export async function handler(event) {
 return {
   statusCode: 200,
   headers: { "Content-Type": "text/plain" },
   body: `Hello, World! Your request was received at ${event.requestContext.time}.`,
 };
}
```

The backend is all set up. Run the `npx sst start` command to deploy the backend to AWS.

```js
Stack dev-my-sst-app-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://w079px97l2.execute-api.us-east-1.amazonaws.com
    IdentityPoolId: us-east-1:04a0c944-8017-4d88-a563-080a61dd2d38
```

## Integrating Your App With Auth0 

To integrate your React frontend application with Auth0, we’ll leverage the AWS Amplify library to make it easier to work with. Install [React with the Create React App](https://serverless-stack.com/chapters/create-a-new-reactjs-app.html) and [set it up to work with Amplify](https://serverless-stack.com/chapters/configure-aws-amplify.html).

Once this setup is complete, create `Home` and `Login` components.

For `Login`, we just want to render the Auth0 sign-up/sign-in button:

```js
import '../App.css';
import { AmplifyAuth0Button, AmplifySignUp } from '@aws-amplify/ui-react';
import config from "../appConfig.json";



const Login = () => {
   return (
       <>
           <div style={{ width: "50%" }}>
               <AmplifySignUp></AmplifySignUp>
               <AmplifyAuth0Button config={config} />
           </div>

       </>

   );
}

export default Login;
```

The `AmplifyAuth0Button` component will do all the work for you—just import and render.

This is how it will look:

![Auth0 Login](https://i.imgur.com/T2wJ58Y.png)

That looks simple, right?

Let’s dive into the settings and configuration to make it work before we make an API call.

### Configuring the File 

In this file, we’ll save all the configurations Auth0 needs to work properly with AWS Amplify.

The file should look like this:

```json
{
   "domain": "dev-8wt5p93b.us.auth0.com",
   "clientID": "2Ew7slhEmNyKEzHPJ4Et2iEJapw7dIry",
   "scope": "openid username",
   "redirectUri": "http://localhost:3000/",
   "returnTo": "http://localhost:3000/",
   "responseType": "token id_token"
}
```

You’ll get all of this information from your Auth0 dashboard.

Again, since Auth0 is not directly supported as one of the federated auth providers, we’ll have to set it up manually on the AWS Management Console to use it. 

### Setting Up the AWS Console

Run `amplify auth console` on your terminal and choose the `User Pool` option. 

![Amplify auth console](https://i.imgur.com/z7HQKEc.png)

This will take you to the AWS website. Navigate to Identity Providers in the Federation tab.

![Federation](https://i.imgur.com/kwiJbtS.png)

Once that opens, click on the **OpenID Connect** icon. A form will open up for you. Fill it with your credentials from the Auth0 dashboard.

![Identity providers](https://i.imgur.com/X801YLY.png)

Here is a filled-out example for you:

![Identity providers example](https://i.imgur.com/9J3EEPt.png)

Navigate to `Attribute Mapping` and choose the attributes you want to get from the user.

Once these settings are completed and saved, come back to your React code and we’ll update the Amplified config file—`aws-exports.js`. 

Specifically, update: `"aws_cognito_identity_pool_id"`: `"us-east-1:04a0c944-8017-4d88-a563-090a31df2638"` replaces the value with the value you have from your SST output.

You should change the API object as well with the data from your SST backend:

```js
   "API": {
       "endpoints": [
           {
               "name": "random",
               "endpoint": "https://f07997l2.execute-api.us-east-1.amazonaws.com",
               "service": "lambda",
               "region": "us-east-1"
           }
       ]
   }

```

And the full `aws-export.js` code should be similar to this:

```js
const awsmobile = {
   "aws_project_region": "us-east-1",
   "aws_cognito_identity_pool_id": "us-east-1:04a0c944-8017-4d88-a563-080a61dd2d38",
   "aws_cognito_region": "us-east-1",
   "aws_user_pools_id": "us-east-1_dhen52ZSw",
   "aws_user_pools_web_client_id": "261oisqotkglra9vrecci78qim", 
   "Auth": {
       "secure": "false"
   },
   "API": {
       "endpoints": [
           {
               "name": "random",
               "endpoint": "https://f07997l2.execute-api.us-east-1.amazonaws.com",
               "service": "lambda",
               "region": "us-east-1"
           }
       ]
   },
   "oauth": {
       "domain": "e-dev.auth.us-east-1.amazoncognito.com",
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
Now let’s create the `Home` component. Here is where we’ll call our private API endpoint if the user is logged in.

```js
import "bootstrap/dist/css/bootstrap.css"
import { useState } from "react";
import '../App.css';
import Amplify, { API, Auth } from 'aws-amplify';
import config from "../appConfig.json";
import awsexports from "../aws-exports";
Amplify.configure(awsexports);

const Home = (props) => {
   const [credential, setCredential] = useState("");
   const [isLoggedIn, setIsLoggedIn] = useState(false);
   const [id, setId] = useState("Anonymous");
   const [randomResult, setRandomResult] = useState("")

   //Let's get the auth parameters returned by Auth0 from your url
   const getFromAuth0 = () => {
       const urlParams = Object.fromEntries([...new URLSearchParams(props.location.hash)]);
       return {
           idToken: urlParams.id_token,
           expiresIn: urlParams.expires_in,
           domain: config.domain
       }
   };

const { idToken, domain, username, expiresIn } = getFromAuth0(); // get the user credentials and info from auth0
  
   if (!isLoggedIn) {


       Auth.federatedSignIn(
           domain, // The Auth0 Domain,
           {
               token: idToken, // The id token from Auth0
               // expires_at means the timestamp when the token provided expires,
               // here we can derive it from the expiresIn parameter provided,
               // then convert its unit from second to millisecond, and add the current timestamp
               expires_at: expiresIn * 1000 + new Date().getTime() // the expiration timestamp
           },
           {
               // the user object, you can put whatever property you get from the Auth0
               // for example:
               username
           }
       ).then(credential => {
           // console.log(cred);
       });

       Auth.currentAuthenticatedUser().then((data) => {
           setCredential(data.token);
           setIsLoggedIn(true)
       });

       Auth.currentAuthenticatedUser().then((data) => {
           setId(data.id)
       });
   };

   if (isLoggedIn) {
       API.get("random", "/private", {
           headers: {
               Authorization: `Bearer ${credential}`
           }

       }).then((result) => {
           setRandomResult(result)
       }).catch((error) => {
           console.log(error.message)
       })
   }

   return (
       <div className="App">
           {isLoggedIn & <p> Hi, {id}. {randomResult} </p> || <p> Welcome, please <a href="/auth" className="login" >Signup/Login</a> to generate a random number</p>}
       </div>
   );
}

export default Home;
```
In the above code, we set Amplify to use the configuration in the `awsexports.js` file. We use ` Auth.federatedSignIn` to sign the user in:

```js
Amplify.configure(awsexports);
```

Then we use the `Auth.federatedSignIn` to log the user in with the returned `ID Token` from Auth0. The response from Auth0 contains the expiration date of the token, the user object that we’ll use to generate the credentials we need to make a call to our AWS Lambda function API.

Once this part is completely set up, you can run the React app with `npm start.` And that’s it.

You can check out the [backend repository here](https://github.com/ezesundayeze/aws-auth0) and the [React frontend repository here](https://github.com/ezesundayeze/aws-serverless-auth0-react-amplify) on GitHub.
