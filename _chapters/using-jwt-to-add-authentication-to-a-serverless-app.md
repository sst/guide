---
layout: post
title: Using JWT to add authentication to a serverless app
date: 2021-08-05 00:00:00
lang: en
description: 
ref: using-jwt-to-add-authentication-to-a-serverless-app
comments_id: 
---

Let’s get started:

## Requirements

* Node.js >= 10.15.1
* We’ll be using Node.js (or ES) in this example, but you can also use TypeScript
* An [AWS account](https://serverless-stack.com/chapters/create-an-aws-account.html) with the [AWS CLI configured locally](https://serverless-stack.com/chapters/configure-the-aws-cli.html)

## Set Up an SST Application with [SST CLI](https://www.npmjs.com/package/@serverless-stack/cli)

```shell
npx create-serverless-stack@latest jwt-sst

 cd jwt-sst  
```

Once the installation is complete, we’ll have a starter template for our project. The app structure should look like this:

![App file structure](https://i.imgur.com/gV3eKJg.png)

Let’s modify the `lib/MyStack.js` file with the code required to set up authentication on our serverless API.

First, let’s add [the code to create a User Pool](https://docs.serverless-stack.com/constructs/Auth#allowing-users-to-sign-in-using-user-pool) with an email address setting self-sign-up to true, so users can sign up:

```js
   // Create User Pool
    const userPool = new cognito.UserPool(this, "UserPool", {
      selfSignUpEnabled: true, // Allow users to sign up
      signInAliases: { email: true }, // Set email as an alias
      signInCaseSensitive: false, 
    });
```

Next, let’s add the code to create a User Pool Client with the User Pool we created initially:

```js
   // Create User Pool Client
    const userPoolClient = new cognito.UserPoolClient(this, "UserPoolClient", {
      userPool,
    });
```

In the same file `lib/MyStack.js`, let’s add the code to create an API:

```js
   // Create Api
    const api = new sst.Api(this, "Api", {
      defaultAuthorizer: new apiAuthorizers.HttpUserPoolAuthorizer({
        userPool,
        userPoolClient,
      }),

      defaultAuthorizationType: sst.ApiAuthorizationType.JWT,

      routes: {
        "GET /private": "src/private.handler",
        "GET /public": {
          function: "src/public.handler",
          	authorizationType: sst.ApiAuthorizationType.NONE,
        },
      },
    });
```

In the code above, we set the default authorization type to JWT, so unless we explicitly set the authorization type to something else, our API will always require a JWT authorization type.

Now we’ll define our API outputs. These outputs will be displayed each time we run the API, so we can always use them on the client side.

```js
   // Show the API endpoint and other info in the output
    this.addOutputs({
      ApiEndpoint: api.url,
      UserPoolId: userPool.userPoolId,
      UserPoolClientId: userPoolClient.userPoolClientId,
    });

```

Finally, let’s create the two lambda functions for the API route we have defined in the `lib/MyStack.js` file.

In `src/public.js` add the following code:

```js
​​export async function main() {
 return {
   statusCode: 200,
   body: "Hello Stranger!",
 };
}
```

While in the `src/private.js` file add:

```js
​​export async function main() {
 return {
   statusCode: 200,
   body: "Hello User!",
 };
}
```

So depending on the API we call, we can expect to get the result shown above. 

Go ahead and run the API by running this command on your terminal:

```shell
npx sst start
```

If everything goes well, you should see an output similar to this:

```shell
Stack dev-jwt-sst-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://yx763b25qj.execute-api.us-east-1.amazonaws.com
    UserPoolClientId: 5kihlmrfhl6o08ge8qmqv797fa
    UserPoolId: us-east-1_AYXs3ofmy
```

Great job. Keep the `UserPoolClientId` and the `UserPool` ID in a safe place. We’ll use them in  the course of this tutorial to connect the frontend with the API.

Let’s try the public API to make sure it works. Make a GET request to the public route with [Postman](https://yx763b25qj.execute-api.us-east-1.amazonaws.com/public).

Here is the result:

![Public route](https://i.imgur.com/nPaSZan.png)

And here is the result for the private route:

![Private route](https://i.imgur.com/3Dt1Llq.png)

As you can see, the private route says `Unauthorized`.

Let’s set up a frontend with HTML, CSS, and JavaScript with a registration and login form so we can authenticate a user and allow them to invoke the `private` route.

We’ll leverage [AWS Amplify](https://aws.amazon.com/amplify/) to make the process easy. Install Amplify by running:

```shell
npm install aws-amplify && amplify init 
```

Next, create [all the HTML files](https://github.com/ezesundayeze/aws-jwt-sst-amplify) we need to complete our auth flow => a sign-in page `signin.html`, code confirmation page `confirm.html`, and sign-up page, `signup.html`.

```shell
touch signin.html confirm.html signup.html protected.html 
```

After sign-up, users will be emailed a code that they’ll need to enter on your confirmation page. Once their registration has been confirmed, they can log in to make the API request.

Let’s go over each page.

First, you’ll need to add AWS Auth to the application to use the Auth module appropriately. Type `amplify add auth` and follow the prompts to add it to the app. 

Then update your `aws-exports.js` file to contain the API endpoints and your API identity configurations, as shown below:

```js

const awsmobile = {
   "aws_project_region": "us-east-1",
   "aws_cognito_identity_pool_id": "us-east-1:cb618a0b-4290-40ed-a61d-8f303a13ab83",
   "aws_cognito_region": "us-east-1",
   "aws_user_pools_id":"us-east-1_AYXs3ofmy",  //change this to your UserPoolId from your API output
   "Aws_user_pools_web_client_id":"5kihlmrfgfhjo08ge8qmqvhgj", // Here use your UserPoolClientId in your api output
   "API": {
       "endpoints": [
           {
               "name": "private",
               "endpoint": "https://yx763t25qj.execute-api.us-east-1.amazonaws.com", //your endpoint
               "service": "lambda",
               "region": "us-east-1"
           }
       ]
   }
};
```

## Sign Up

Let’s add the JavaScript to sign up the user:

```js
import { Auth } from 'aws-amplify';

(function () {
   const signupForm = document.getElementById('signup-form');
   require("./app");

   async function signUp(e) {
       e.preventDefault();

       const email = document.getElementById('email');
       const password = document.getElementById('password');

       try {
           const { user } = await Auth.signUp({
               username: email.value,
               password: password.value,
           });
           localStorage.setItem("username", email.value);
           location.replace("/confirm.html")
       } catch (error) {
           console.log('error signing up:', error);
       }
   }
   signupForm.addEventListener('submit', signUp);
})()
```

In the code above, we are letting the user create an account with their email address as their username and set a password. 

![Sign-up form](https://i.imgur.com/D67IWlJ.png)

Once the registration is successful, the user will be sent an email with a confirmation code. They will need to use the code to verify their registration. Here is how the confirmation page looks:

![Confirmation](https://i.imgur.com/PY50UGp.png)

And this is the sample code to confirm sign-up. Just pass the confirmation code and the username to the `Auth.confirmSignUp` method as shown below to complete the registration.

```js
import { Auth } from 'aws-amplify';
require("./app");

const confirmationForm = document.getElementById("confirmation-form")

async function confirmSignUp(e) {
   e.preventDefault();

   const code = document.getElementById("code");
   const username = localStorage.getItem("username")

   try {
       await Auth.confirmSignUp(username, code.value);
       console.log("Logged in successfully");
       location.replace("/signin.html")
   } catch (error) {
       console.log('error confirming sign up', error);
   }
}

confirmationForm.addEventListener("submit", confirmSignUp)
```

## Sign In

To sign in, we’ll send the username (in the context of this article, the user’s email is the same as the email address) and password to AWS by calling the `Auth.signIn(email.value, password.value)` function with the required parameters.

Create a file for the sign in => `signin.js` and add the following code: 

```js
import { Auth } from 'aws-amplify';
require("./app");
const signinForm = document.getElementById('signin-form');

async function signIn(e) {
   e.preventDefault();
   const email = document.getElementById('email');
   const password = document.getElementById('password');

   try {
       const user = await Auth.signIn(email.value, password.value);
       location.replace(‘/protected.html’)
       console.log("Logged in successfully", user)
   } catch (error) {
       console.log('error signing in', error);
   }
}

signinForm.addEventListener("submit", signIn)
```

If the username and password are correct, you will see the Cognito user object in the console:

![Cognito user object](https://i.imgur.com/mkPok3d.png)

From there, you can redirect the user to a protected page. For this example we’ll use the page we’ve created.

## Protected Page

It’s time to allow our authenticated user to make an API call to the lambda API. We’ll extract the JWT token using this construct: `(await Auth.currentSession()).accessToken.jwtToken`. Since this is an async function, it might not be completed before the API gets called, so we’ll use JavaScript’s `Promise.all` to ensure we only call the API when the Promise is fulfilled. 

```js
import Amplify, { Auth, API, a } from 'aws-amplify';
import awsexport from "./aws-exports";
Amplify.configure(awsexport);

const token = (async () => {
   return ((await Auth
       .currentSession()).accessToken.jwtToken)
})();


Promise.all([token]).then(async (values) => {
  
   const result = await API.get("private", "/private", {
       headers: { Authorization: `Bearer ${values[0]}` }
   });
  
   let message = document.getElementById("message");
   message.innerHTML = result;
});
```

Once the protected page is launched, you’ll see the following in your network and on your HTML page: 

![API called successfully](https://i.imgur.com/XH0Bn1m.png)

We’ve succeeded in authenticating a user and making an API call to an authenticated route. You can find the full [API sample code in this GitHub repository](https://github.com/ezesundayeze/jwt-sst-api) and the [frontend sample in this repository](https://github.com/ezesundayeze/aws-jwt-sst-amplify).
