---
layout: post
title: Using Cognito to add authentication to a serverless app
date: 2021-07-27 00:00:00
lang: en
description: In this chapter we look at how to use Amazon Cognito to add authentication to a serverless API. We'll also look at how to connect to this API using AWS Amplify in a React.js app.
ref: using-cognito-to-add-authentication-to-a-serverless-app
comments_id: 
---

{% capture repo_url %}{{ site.sst_github_repo }}{{ site.sst_github_examples_prefix }}react-app-auth-cognito{% endcapture %}

In the [previous chapter]({% link _chapters/how-to-add-authentication-to-a-serverless-app.md %}) we looked the basics of adding authentication to a serverless app. In this chapter we look at how to use [Amazon Cognito](https://aws.amazon.com/cognito/) to add authentication to a serverless API. We'll also look at how to connect to this API using [AWS Amplify](https://aws.amazon.com/amplify/) in a [React.js](https://reactjs.org) app.

To understand this better we'll be using an example SST application that's been created for this:

[**{{ page.repo_url }}**]({{ page.repo_url }})

This example SST app has a couple of key parts:

- **The `lib/` directory.** This contains the code that describes the infrastructure of your serverless app. It works by leveraging [AWS CDK](https://serverless-stack.com/chapters/what-is-aws-cdk.html) to create the infrastructure. This includes our API, our Cognito services, and our frontend static site.
- **The `src/` directory.** This is where the application code resides. The code that will run when your API is called will live here.
- **The `frontend/` directory.** This is where our frontend React.js application is. It'll be connecting to our APIs.

Moreso, it comes with a configuration file, `sst.json`, which contains the environment configuration information. Here is what it looks like:

```json
{
   "name":"react-app-auth-cognito",
   "stage":"dev",
   "region":"us-east-1",
   "lint":true
}
```

The configuration above implies that the app will be deployed to the development environment called `dev` in the `us-east-1` region.

Let’s start with looking at how to add a Cognito User Pool client.

### How to Add Cognito

In the [previous chapter]({% link _chapters/how-to-add-authentication-to-a-serverless-app.md %}) we talked about the various parts of Cognito ([User Pools and Identity Pools]({% link _chapters/cognito-user-pool-vs-identity-pool.md %})).

SST makes it easy to add these to your application. In [`lib/MyStack.js`]() you'll notice.

``` js
// Create a Cognito User Pool to manage auth
const auth = new sst.Auth(this, "Auth", {
  cognito: {
    userPool: {
      // Users will login using their email and password
      signInAliases: { email: true, phone: true },
    },
  },
});
```

This is using the SST [`Auth`](https://docs.serverless-stack.com/constructs/Auth) construct to create a Cognito User Pool and an Identity Pool.

#### Aliases

In this case we are allowing users to login with their email and phone number as their username.

You can also optionally allows users to create a username and login using that.

```js
const auth = new sst.Auth(this, "Auth", {
  cognito: {
    userPool: {
      signInAliases: {
        email: true,
        phone: true,
        username: true,
        preferredUsername: true,
      },
    },
  },
});
```

#### Social Logins

In this example we are not setting up any social logins. We'll do that in an upcoming chapter. But for a quick look, here's roughly what adding other social login providers will look like:

```js
new Auth(this, "Auth", {
  facebook: { appId: "419718329085014" },
  apple: { servicesId: "com.myapp.client" },
  amazon: { appId: "amzn1.application.24ebe4ee4aef41e5acff038aee2ee65f" },
  google: {
    clientId: "38017095028-abcdjaaaidbgt3kfhuoh3n5ts08vodt3.apps.googleusercontent.com",
  },
});
```

#### Cognito Triggers

You also might want to trigger. Before and after the authentication, you might want to trigger some actions. The [Cognito Triggers](https://docs.serverless-stack.com/constructs/Auth#authuserpooltriggers) allow you to define Lambda functions that get executed for specific events.

```js
new Auth(this, "Auth", {
  cognito: {
    triggers: {
      preAuthentication: "src/preAuthentication.main",
      postAuthentication: "src/postAuthentication.main",
    },
  },
});
```

### Adding an API

Now let's look at how we can use Cognito to secure our API. In `lib/MyStack.js` of our example, you'll notice our SST [`Api`](https://docs.serverless-stack.com/constructs/Api) definition.

``` js
// Create an HTTP API
const api = new sst.Api(this, "Api", {
  // Secure it with IAM Auth
  defaultAuthorizationType: sst.ApiAuthorizationType.AWS_IAM,
  routes: {
    "GET /private": "src/private.handler",
    // Make an endpoint public
    "GET /public": {
      function: "src/public.handler",
      authorizationType: sst.ApiAuthorizationType.NONE,
    },
  },
});

// Allow authenticated users to invoke the API
auth.attachPermissionsForAuthUsers([api]);
```

We are going to create a simple API that generates random numbers. It'll have a public and a private route. While anyone can generate a random number on the public route, only logged-in users can generate random numbers from the private route.

Notice the `defaultAuthorizationType: sst.ApiAuthorizationType.AWS_IAM`. This is to ensure that by default you are setting the authorization to allow only users with a valid `AWS_IAM` permission to access your routes.

You’ll also notice that you set the `authorizationType` to `NONE` in the public route, overriding the default behavior described earlier.

Finally, `auth.attachPermissionsForAuthUsers([api])` tells AWS that the authenticated users to our Cognito User Pool can access the API that we just defined.

#### Adding Lambda functions

Next, let's quickly look at the Lambda functions that'll be powering our API. Inside the `src/` directory we have a couple of files that generate random numbers for us.

For example, here's what `src/private.js` looks like.

``` js
export async function handler() {
  const rand = Math.floor(Math.random() * 10);

  return {
    statusCode: 200,
    headers: { "Content-Type": "text/json" },
    body: JSON.stringify({ message: `Private Random Number: ${rand}` }),
  };
}
```

### Adding a React Static Site

We can now turn our attention to the frontend part of our application. In `lib/MyStack.js` you'll notice the SST [`ReactStaticSite`](https://docs.serverless-stack.com/constructs/ReactStaticSite) definition.

``` js
// Deploy our React app
const site = new sst.ReactStaticSite(this, "ReactSite", {
  path: "frontend",
  // Pass in our environment variables
  environment: {
    REACT_APP_API_URL: api.url,
    REACT_APP_REGION: scope.region,
    REACT_APP_USER_POOL_ID: auth.cognitoUserPool.userPoolId,
    REACT_APP_IDENTITY_POOL_ID: auth.cognitoCfnIdentityPool.ref,
    REACT_APP_USER_POOL_CLIENT_ID:
      auth.cognitoUserPoolClient.userPoolClientId,
  },
});
```

The key here is that we are [setting the outputs from our backend as environment variables in React]({% link _chapters/setting-serverless-environments-variables-in-a-react-app.md %}). Specifically, we are passing in the:

1. API endpoint
2. Region of our serverless app
3. Id of our Cognito User Pool
4. Id of our Cognito Identity Pool
5. And the Id of the Cognito User Pool client

Now we are ready to create our React app.

### Creating a React app

In this example we are using [Create React App](https://create-react-app.dev). The only difference is that we are using [`@serverless-stack/static-site-env`](@serverless-stack/static-site-env) CLI to load the environments variables from our SST app.

You'll notice this in the `frontend/package.json`.

``` json
"scripts": {
  "start": "sst-env -- react-scripts start",
  "build": "react-scripts build",
  "test": "react-scripts test",
  "eject": "react-scripts eject"
}
```

We are also using [Bootstrap](https://getbootstrap.com), [React Bootstrap](https://github.com/react-bootstrap/react-bootstrap), and [React Router](https://reactrouter.com) in this example but we are not going into them in detail here.

However, we'll look at how we use [AWS Amplify](https://aws.amazon.com/amplify/) to connect to the API that we defined above.

#### Configure AWS Amplify

To start with, we'll configure it in `frontend/src/index.js`.

``` js
// Init Amplify
Amplify.configure({
  Auth: {
    mandatorySignIn: true,
    region: process.env.REACT_APP_REGION,
    userPoolId: process.env.REACT_APP_USER_POOL_ID,
    identityPoolId: process.env.REACT_APP_IDENTITY_POOL_ID,
    userPoolWebClientId: process.env.REACT_APP_USER_POOL_CLIENT_ID,
  },
  API: {
    endpoints: [
      {
        name: "random-api",
        region: process.env.REACT_APP_REGION,
        endpoint: process.env.REACT_APP_API_URL,
      },
    ],
  },
});
```

You'll notice that we are using the environment variables that we had set above.

#### Handling Signups

To allow users to sign up for our application, let's look at `frontend/src/components/Signup.js`.

First we have a simple form that we've created using React Bootstrap.

``` jsx
<Form onSubmit={handleSubmit}>
  <Form.Group controlId="email" size="lg">
    <Form.Label>Email</Form.Label>
    <Form.Control
      autoFocus
      type="email"
      value={fields.email}
      onChange={handleFieldChange}
    />
  </Form.Group>
  <Form.Group controlId="password" size="lg">
    <Form.Label>Password</Form.Label>
    <Form.Control
      type="password"
      value={fields.password}
      onChange={handleFieldChange}
    />
  </Form.Group>
  <Form.Group controlId="confirmPassword" size="lg">
    <Form.Label>Confirm Password</Form.Label>
    <Form.Control
      type="password"
      onChange={handleFieldChange}
      value={fields.confirmPassword}
    />
  </Form.Group>
  <Button
    block
    size="lg"
    type="submit"
    variant="success"
    disabled={isLoading || !validateForm()}
  >
    Signup
  </Button>
</Form>
```

When we submit this form, we use the 

``` js
async function handleSubmit(event) {
  event.preventDefault();

  setIsLoading(true);

  try {
    // Sign up the user
    const newUser = await Auth.signUp({
      username: fields.email,
      password: fields.password,
    });
    setIsLoading(false);
    setNewUser(newUser);
  } catch (e) {
    alert(e);
    setIsLoading(false);
  }
}
```

``` js
import React, { useState } from "react";
import { Auth } from "aws-amplify";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import { useHistory } from "react-router-dom";
import { useFormFields } from "../lib/hooksLib";
import "./Signup.css";

export default function Signup({ userHasAuthenticated }) {
  const [fields, handleFieldChange] = useFormFields({
    email: "",
    password: "",
    confirmPassword: "",
    confirmationCode: "",
  });
  const history = useHistory();
  const [newUser, setNewUser] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  function validateForm() {
    return (
      fields.email.length > 0 &&
      fields.password.length > 0 &&
      fields.password === fields.confirmPassword
    );
  }

  function validateConfirmationForm() {
    return fields.confirmationCode.length > 0;
  }

  async function handleSubmit(event) {
    event.preventDefault();

    setIsLoading(true);

    try {
      // Sign up the user
      const newUser = await Auth.signUp({
        username: fields.email,
        password: fields.password,
      });
      setIsLoading(false);
      setNewUser(newUser);
    } catch (e) {
      alert(e);
      setIsLoading(false);
    }
  }

  async function handleConfirmationSubmit(event) {
    event.preventDefault();

    setIsLoading(true);

    try {
      // Check the user's confirmation code
      await Auth.confirmSignUp(fields.email, fields.confirmationCode);
      // Sign the user in
      await Auth.signIn(fields.email, fields.password);

      userHasAuthenticated(true);
      // Redirect to the homepage
      history.push("/");
    } catch (e) {
      alert(e);
      setIsLoading(false);
    }
  }

  function renderConfirmationForm() {
    return (
      <Form onSubmit={handleConfirmationSubmit}>
        <Form.Group controlId="confirmationCode" size="lg">
          <Form.Label>Confirmation Code</Form.Label>
          <Form.Control
            autoFocus
            type="tel"
            onChange={handleFieldChange}
            value={fields.confirmationCode}
          />
          <Form.Text muted>Please check your email for the code.</Form.Text>
        </Form.Group>
        <Button
          block
          size="lg"
          type="submit"
          variant="success"
          disabled={isLoading || !validateConfirmationForm()}
        >
          Verify
        </Button>
      </Form>
    );
  }

  function renderForm() {
    return (
      <Form onSubmit={handleSubmit}>
        <Form.Group controlId="email" size="lg">
          <Form.Label>Email</Form.Label>
          <Form.Control
            autoFocus
            type="email"
            value={fields.email}
            onChange={handleFieldChange}
          />
        </Form.Group>
        <Form.Group controlId="password" size="lg">
          <Form.Label>Password</Form.Label>
          <Form.Control
            type="password"
            value={fields.password}
            onChange={handleFieldChange}
          />
        </Form.Group>
        <Form.Group controlId="confirmPassword" size="lg">
          <Form.Label>Confirm Password</Form.Label>
          <Form.Control
            type="password"
            onChange={handleFieldChange}
            value={fields.confirmPassword}
          />
        </Form.Group>
        <Button
          block
          size="lg"
          type="submit"
          variant="success"
          disabled={isLoading || !validateForm()}
        >
          Signup
        </Button>
      </Form>
    );
  }

  return (
    <div className="Signup">
      {newUser === null ? renderForm() : renderConfirmationForm()}
    </div>
  );
}
```




An [Amazon Cognito User Pool](https://serverless-stack.com/chapters/create-a-cognito-user-pool.html) Client is a resource that allows you to generate authentication tokens used to authorize a user for an application.

To demonstrate how to add the User Pool Client to an application, let’s build a simple random number generator with SST that will have:

- A secure route to generate random numbers
- And a public route as well

So, let’s create the routes. Open the `lib/MyStack.js` file and modify it to include the public and private route as shown below:

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
    constructor(scope, id, props) {
        super(scope, id, props);

        // Create a HTTP API
        const api = new sst.Api(this, "Api", {

            //Set the default authorization
            defaultAuthorizationType: sst.ApiAuthorizationType.AWS_IAM,
            routes: {
                "GET /private": "src/private.handler",
                "GET /public": {
                    function: "src/public.handler",
                    authorizationType: sst.ApiAuthorizationType.NONE,
                },
            },
        });

        // Show the endpoint in the output
        this.addOutputs({
            "ApiEndpoint": api.url,
        });
    }
}
```

Now, let’s explore the different ways you can add authentication with AWS Cognito to your application.

## Using Aliases

There are two ways to log in users using aliases.

### 1. With a Username or Alias

To enable this functionality with SST, set the `UserPool` prop to:

```js
{
    signInAliases: {
        username: true,
        email: true,
        phone: true
        preferredUsername: true,
    }
}
```

Make this modification in the `lib/MyStack.js` file like so:

```js
const auth = new sst.Auth(this, "Auth", {
    // Create a Cognito User Pool to manage user's authentication info.
    cognito: {
        userPool: {
            // Users will login using their email or phone number and password
            signInAliases: {
                username: true,
                email: true,
                phone: true
                preferredUsername: true,
            },
        },
    },
});

```

### 2. With an Email or Phone Number 

To enable this functionality with SST, set the `UserPool` prop in the `lib/MyStack.js` file to:

```js
{
    signInAliases: {
        email: true,
        phone: true,
    }
}
```

It should look like this in the file:

```js
const auth = new sst.Auth(this, "Auth", {
    // Create a Cognito User Pool to manage user's authentication info.
    cognito: {
        userPool: {
            // Users will login using their email or phone number and password
            {
                signInAliases: {
                    email: true,
                    phone: true,
                }
            }
        },
    },
});

```

Then, still in same file `lib/MyStack.js`, set the permission on the API with the following code:

```js
// Set the private API to allow only authenticated users to call the API
auth.attachPermissionsForAuthUsers([api]);
```

Let’s implement an option that uses either username or phone number and password. Add the following object to your SST stack class below the `api` constant in the `/lib/MyStack.js` file:

```js
const auth = new sst.Auth(this, "Auth", {
// Create a Cognito User Pool to manage user's authentication info.
cognito: {
   userPool: {
   // Users will login using their email or phone number and password
   signInAliases: { email: true, phone: true },
  },
},
});
```

And finally, modify the `addOutputs` construct to include the following AWS Cognito Identify parameters:

```js
this.addOutputs({
    ApiEndpoint: api.url,
    UserPoolId: auth.cognitoUserPool.userPoolId,
    IdentityPoolId: auth.cognitoCfnIdentityPool.ref,
    UserPoolClientId: auth.cognitoUserPoolClient.userPoolClientId,
});
```

## Social Login

Also, your users can log in with their social media accounts, such as Facebook, Google, or Twitter. Using SST, you can easily enable social media login by adding the social login configuration to the `Auth` construct as shown below:

```js
new Auth(this, "Auth", {
   facebook: { appId: "419718329085014" },
   apple: { servicesId: "com.myapp.client" },
   amazon: { appId: "amzn1.application.24ebe4ee4aef41e5acff038aee2ee65f" },
   google: {
   clientId: "38017095028-abcdjaaaidbgt3kfhuoh3n5ts08vodt3.apps.googleusercontent.com",
},
});
```

SST makes it easy to log in with Auth0 using the following configuration:

```js
new Auth(this, "Auth", {
auth0: {
   domain: "https://myorg.us.auth0.com",
   clientId: "UsGRQJJz5sDfPQDs6bhQ9Oc3hNISuVif",
},
});
```

Before and after the authentication, you might want to trigger some actions. The [Cognito Trigger](https://docs.serverless-stack.com/constructs/Auth#authuserpooltriggers) allows you to define triggers that get executed in this manner. You can configure it as shown below:

```js
new Auth(this, "Auth", {
cognito: {
    triggers: {
    preAuthentication: "src/preAuthentication.main",
    postAuthentication: "src/postAuthentication.main",
    },
},
});
```

So, at this point, your API should look like so:

```js
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
    constructor(scope, id, props) {
        super(scope, id, props);
        // Create a HTTP API
        const api = new sst.Api(this, "Api", {
            defaultAuthorizationType: sst.ApiAuthorizationType.AWS_IAM,
            routes: {
                "GET /private": "src/private.handler",
                "GET /public": {
                    function: "src/public.handler",
                    authorizationType: sst.ApiAuthorizationType.NONE,

                },
            },
        });

        const auth = new sst.Auth(this, "Auth", {

            // Create a Cognito User Pool to manage the user's authentication info.

            cognito: {
                userPool: {
                    // Users will login using their email or phone number and password
                    signInAliases: {
                        email: true,
                        phone: true
                    },
                },

            },

        });

        // Show the endpoint in the output
        this.addOutputs({
            ApiEndpoint: api.url,
            UserPoolId: auth.cognitoUserPool.userPoolId,
            IdentityPoolId: auth.cognitoCfnIdentityPool.ref,
            UserPoolClientId: auth.cognitoUserPoolClient.userPoolClientId,
        });

        // Allow authenticated users to invoke the API
        auth.attachPermissionsForAuthUsers([api]);
    }
}
```

Run `npx sst start` on your terminal to start and deploy the application in debug mode.

If it all goes well, you should see a result that looks like this:

```shell
Preparing your SST app
Transpiling source
Linting source
=======================

Deploying debug stack
=======================
...

Stack dev-react-app-auth-cognito-debug-stack
Outputs:
UserPoolClientId: 2turafvi6bjbv9pomrp61lljo
UserPoolId: us-east-1_c4SsgOvxg
ApiEndpoint: https://24ji2e01n9.execute-api.us-east-1.amazonaws.com

IdentityPoolId: us-east-1:9acb4572-dd8c-4457-a2b5-2a1e19541683

```

You can copy the `ApiEndpoint` and test both API routes on [Postman]([https://www.postman.com/](https://www.postman.com/)). You’ll need the other outputs later.

**Public Route**

![Get request on the public route](https://i.imgur.com/wKUUN2k.png)

**Private Route**

![Get request on the private route](https://i.imgur.com/XfPxUot.png)

Notice the forbidden error on the private route? That indicates that you need to be authenticated. Let’s build the frontend with ReactJS and allow users to sign up, log in, and generate random numbers from the private API route.

## Frontend App

Let’s create a simple frontend with ReactJS that will allow you to sign up, sign in, and invoke your serverless APIs.

### Set Up

Set up a simple ReactJS boilerplate with [Create React App](https://create-react-app.dev/) by running `npx create-react-app my-app`. Install the dependencies you will need to build this application by running this command when the `create-react-app` command is completely executed:

```bash
$ npm install aws-sdk amazon-cognito-identity-js react-router-dom axios bootstrap react-bootstrap
```

### Sign Up

![Signup Page](https://i.imgur.com/tEQXYPR.png)

Create a signup component `src/Components/Signup.js` and add the following code to it:

```js
import React, {
    useState
} from "react";
import {
    useHistory
} from "react-router-dom";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import "./Auth.css"
import 'cross-fetch/polyfill';

import {
    CognitoUserPool,
    CognitoUserAttribute,
} from 'amazon-cognito-identity-js';

export default function Signup() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    let history = useHistory();

    function validateForm() {
        return email.length > 0 && password.length > 0;
    }

    function handleSubmit(event) {
        event.preventDefault();

        var poolData = {
            UserPoolId: 'us-east-1_gghjkjg', // Your user pool id here
            ClientId: '6lrvb2pvj8pa3m9ndhghhjsd', // Your client id here

        };

        var userPool = new CognitoUserPool(poolData);
        var attributeList = [];

        var dataEmail = {
            Name: 'email',
            Value: email,
        };

        var attributeEmail = new CognitoUserAttribute(dataEmail);
        attributeList.push(attributeEmail);
        userPool.signUp(dataEmail.Value, password, attributeList, null, function(
            err,
            result
        ) {
            if (err) {
                alert(err.message || JSON.stringify(err));
                return;
            }

            var cognitoUser = result.user;
            localStorage.setItem("username", cognitoUser.getUsername());

            history.push("/confirm")
            console.log('user name is ' + cognitoUser.getUsername());
        });
    }

    return (

        <
        div className = "Auth" >
        <
        Form onSubmit = {
            handleSubmit
        } >
        <
        Form.Group size = "lg"
        controlId = "email" >
        <
        Form.Label > Email < /Form.Label> <
        Form.Control autoFocus type = "email"
        value = {
            email
        }
        onChange = {
            (e) => setEmail(e.target.value)
        }
        /> <
        /Form.Group> <
        Form.Group size = "lg"
        controlId = "password" >
        <
        Form.Label > Password < /Form.Label> <
        Form.Control type = "password"
        value = {
            password
        }
        onChange = {
            (e) => setPassword(e.target.value)
        }
        />

        <
        /Form.Group> <
        Button block size = "lg"
        type = "submit"
        disabled = {
            !validateForm()
        } >
        Signup

        <
        /Button>

        <
        /Form>

        <
        /div>

    );

}


```

The signup component will allow users to sign up with their email address and password. Your `UserPoolId` and the `ClientId` are how AWS knows this user should be created for your application.

You’ll grab the `UserPoolId` and `ClientId` from the terminal and add it to your code as shown in the above React component. Then, call the `userPool.signUp` function to register the user. If it all goes well, the newly created user will be returned as the result of the callback function that was passed to the `Signup` function, and a verification code will be sent to the user’s email address.

![Confirmation code](https://i.imgur.com/FeLQdwy.png)

### The Confirmation Component

![Confirmation Page](https://i.imgur.com/gqKwTO7.png)

Once you receive the confirmation code, the next step is to actually confirm it. Create a `ConfirmUser` component to make this happen: `src/Components/ConfirmUser.js`.
 
```js
import  React, { useState } from  'react'
import  Form  from  "react-bootstrap/Form";
import  Button  from  "react-bootstrap/Button";
import  'cross-fetch/polyfill';
import {
CognitoUserPool,
CognitoUser,
} from  'amazon-cognito-identity-js';

export  default  function  ConfirmUser() {
const [token, setToken] = useState("");
const [username, setUsername] = useState("");

function  validateForm() {
return  token.length > 0;
}

function  handleSubmit(event) {

event.preventDefault();
var  poolData = {
UserPoolId:  'us-east-1_gYggfdgf', // Change this to your user pool id 
ClientId:  '6lrvbg2pvj8pa3hm9nfgdgfdf', // change this to your client id

};

setUsername(localStorage.getItem("username"));
console.log(username)
var  userPool = new  CognitoUserPool(poolData);
var  userData = {
Username:  username,
Pool:  userPool,
};

var  cognitoUser = new  CognitoUser(userData);
cognitoUser.confirmRegistration(token, true, function (err, result) {

if (err) {
console.log(err.message || JSON.stringify(err));
return;

}
console.log('call result: ' + result);
});
}

return (
<div  className="Auth">
<Form  onSubmit={handleSubmit}>
<Form.Group  size="lg"  controlId="email">
<Form.Label>Verification Code</Form.Label>
<Form.Control
autoFocus
type="text"
value={token}
onChange={(e) =>  setToken(e.target.value)}
/>
</Form.Group>
<Button  block  size="lg"  type="submit"  disabled={!validateForm()}  >
Confirm
</Button>
</Form>
</div>
);
}
```

To verify the user, initialize the user in your user pool:

```js
var userData = {
    Username: username,
    Pool: userPool,
};
var cognitoUser = new CognitoUser(userData);

```

And invoke the `confirmRegistration` method passing in the `token` you got from your email.

If the code is correct, the API will return a `SUCCESS` response. Otherwise you'll get an error with the reason for the error.

## Sign In

Once the user is verified, you can now sign in. 

Create a sign-in component. The user will enter their email and password in exchange for a token they can use to log in: `id_token` and  `access_tokens`.

```js
import React, {
    useState
} from 'react'
import * as AWS from 'aws-sdk/global';
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import "./Auth.css"
import 'cross-fetch/polyfill';

import {
    CognitoUserPool,
    CognitoUser,
    AuthenticationDetails
} from 'amazon-cognito-identity-js';

export default function Login(params) {

    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");

    function validateForm() {
        return email.length > 0 && password.length > 0;
    }

    function handleSubmit(event) {
        event.preventDefault();

        var authenticationData = {
            Username: email,
            Password: password,
        };

        var authenticationDetails = new AuthenticationDetails(
            authenticationData
        );
        var poolData = {
            UserPoolId: 'us-east-1_gYW7OI6O2', // Change this to your user pool id
            ClientId: '6lrvb2pvj8pa3m9ndbs84hob9h', // Change this to your client id 
        };

        var userPool = new CognitoUserPool(poolData);
        var userData = {
            Username: email,
            Pool: userPool,
        };

        var cognitoUser = new CognitoUser(userData);

        cognitoUser.authenticateUser(authenticationDetails, {
            onSuccess: function(result) {
                var accessToken = result.getAccessToken().getJwtToken();
                console.log(accessToken)
                localStorage.setItem("token", accessToken)

                //POTENTIAL: Region needs to be set if not already set previously elsewhere.

                AWS.config.region = 'us-east-1';

                AWS.config.credentials = new AWS.CognitoIdentityCredentials({

                    IdentityPoolId: 'us-east-1_gYW7OIref', // your identity pool id here

                    Logins: {

                        // Change the key below according to the specific region your user pool is in.

                        'cognito-idp.us-east-1.amazonaws.com/us-east-1_gYW7OIref': result

                            .getIdToken()
                            .getJwtToken(),
                    },
                });

                //refreshes credentials using AWS.CognitoIdentity.getCredentialsForIdentity()
                AWS.config.credentials.refresh(error => {
                    if (error) {
                        console.error(error);
                    } else {
                        // Instantiate aws sdk service objects now that the credentials have been updated.
                        // example: var s3 = new AWS.S3();
                        console.log('Successfully logged!');
                    }
                });

            },

            onFailure: function(err) {
                console.log(err.message || JSON.stringify(err));
            },

        });

    }

    return ( <
        div className = "Auth" >
        <
        Form onSubmit = {
            handleSubmit
        } >

        <
        Form.Group size = "lg"
        controlId = "email" >

        <
        Form.Label > Email < /Form.Label>

        <
        Form.Control autoFocus type = "email"
        value = {
            email
        }
        onChange = {
            (e) => setEmail(e.target.value)
        }
        /> <
        /Form.Group> <
        Form.Group size = "lg"
        controlId = "password" >
        <
        Form.Label > Password < /Form.Label> <
        Form.Control type = "password"
        value = {
            password
        }
        onChange = {
            (e) => setPassword(e.target.value)
        }
        /> <
        /Form.Group> <
        Button block size = "lg"
        type = "submit"
        disabled = {
            !validateForm()
        } >
        Login <
        /Button> <
        /Form> <
        /div>
    )
}
```

If the login is successful, you'll have your access token added to the `localStorage`, which will be used to invoke the API.

![Tokens](https://i.imgur.com/XKgQ2Ng.png)
  
## API Call

Now that the user is authenticated, you can call the private API from React using [Axios](https://www.npmjs.com/package/axios) as shown in the code below:

`src/Components/PrivateRandom.js`
```js
import  axios  from  "axios";
import  React, { useState, useEffect, Fragment } from  "react";

function  PrivateRandom() {
const [result, setResult] = useState("")
const [status, setStatus] = useState(false);

useEffect(() => {
const token = localStorage.getItem("token");
axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

	axios.get("https://24ji2e01n9.execute-api.us-east-1.amazonaws.com/private")
.then((data) => {
	setStatus(true)
	setResult(data.data)
}).catch((error)=>{
	setStatus(false)
});
}, [])

return(
	<Fragment>
		{status && result}
		{!status && "Loading ..."}
	</Fragment>
)
};

export  default  PrivateRandom;
```

With the token passed in to the `Authorization` headers, you are able to make a call to the API securely as an authenticated user.

![Private API call](https://i.imgur.com/T9MUG9E.png)

But you won't need that to invoke the public API. Just make a direct call to the API without a token. It should look like so:

```js

import  axios  from  "axios";

import  React, { useState, useEffect, Fragment } from  "react";

function  PublicRandom() {
const [result, setResult] = useState("")
const [status, setStatus] = useState(false);

useEffect(() => {
axios.get("https://24ji2e01n9.execute-api.us-east-1.amazonaws.com/public")
.then((data) => {
	setStatus(true)
	setResult(data.data)
}).catch((error) => {
console.error(error)
setStatus(false)
});
}, [])
return (

<Fragment>
{status && result}
{!status && "Loading ..."}
</Fragment>
)
};

export  default  PublicRandom;

```

![Public API call](https://i.imgur.com/YsX0m4z.png)

You can also use [AWS Amplified](https://serverless-stack.com/chapters/configure-aws-amplify.html) to generate the frontend ReactJS application (including the generating of the login and signup form automatically) for authentication with the backend. 

Here is a [link](https://github.com/ezesundayeze/aws-cognito-sst) to the API and the [React sample application](https://github.com/ezesundayeze/aws-cognito-react).
