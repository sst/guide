---
layout: example
title: How to add JWT authorization with Cognito User Pool to a serverless API
short_title: Cognito JWT
date: 2021-03-02 00:00:00
lang: en
index: 1
type: jwt-auth
description: In this example we will look at how to add JWT authorization with Cognito User Pool to a serverless API using Serverless Stack (SST). We'll be using the Api and Auth constructs to create an authenticated API.
short_desc: Adding JWT authentication with Cognito.
repo: api-auth-jwt-cognito-user-pool
ref: how-to-add-jwt-authorization-with-cognito-user-pool-to-a-serverless-api
comments_id: how-to-add-jwt-authorization-with-cognito-user-pool-to-a-serverless-api/2338
---

In this example we will look at how to add JWT authorization with [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) to a serverless API using [Serverless Stack (SST)]({{ site.sst_github_repo }}).

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npm init sst -- typescript-starter api-auth-jwt-cognito-user-pool
$ cd api-auth-jwt-cognito-user-pool
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "api-auth-jwt-cognito-user-pool",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `backend/` — App Code

   The code that's run when your API is invoked is placed in the `backend/` directory of your project.

## Setting up the API

Let's start by setting up an API.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import * as cognito from "aws-cdk-lib/aws-cognito";
import { Api, StackContext } from "@serverless-stack/resources";

export function MyStack({ stack }: StackContext) {
  // Create User Pool
  const userPool = new cognito.UserPool(stack, "UserPool", {
    selfSignUpEnabled: true,
    signInAliases: { email: true },
    signInCaseSensitive: false,
  });

  // Create User Pool Client
  const userPoolClient = new cognito.UserPoolClient(stack, "UserPoolClient", {
    userPool,
    authFlows: { userPassword: true },
  });

  // Create Api
  const api = new Api(stack, "Api", {
    authorizers: {
      jwt: {
        type: "user_pool",
        userPool: {
          id: userPool.userPoolId,
          clientIds: [userPoolClient.userPoolClientId],
        },
      },
    },
    defaults: {
      authorizer: "jwt",
    },
    routes: {
      "GET /private": "functions/private.handler",
      "GET /public": {
        function: "functions/public.handler",
        authorizer: "none",
      },
    },
  });

  // Show the API endpoint and other info in the output
  stack.addOutputs({
    ApiEndpoint: api.url,
    UserPoolId: userPool.userPoolId,
    UserPoolClientId: userPoolClient.userPoolClientId,
  });
}
```

This creates a [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html); a user directory that manages user sign up and login. We've configured the User Pool to allow users to login with their email and password.

Note, we are enabling the `userPassword` authentication flow for the purpose of this example. We need this to be able to authenticate a user and receive the JWT token via the AWS CLI. You **should not** enable this authentication flow in production.

We are also creating an API here using the [`Api`]({{ site.docs_url }}/constructs/api) construct. And we are adding two routes to it.

```
GET /private
GET /public
```

By default, all routes have the authorization type `JWT`. This means the caller of the API needs to pass in a valid JWT token. The first is a private endpoint. The second is a public endpoint and its authorization type is overridden to `NONE`.

## Adding function code

Let's create two functions, one for the public route, and one for the private route.

{%change%} Add a `backend/functions/public.ts`.

```ts
export async function handler() {
  return {
    statusCode: 200,
    body: "Hello stranger!",
  };
}
```

{%change%} Add a `backend/functions/private.ts`.

```ts
export async function handler() {
  return {
    statusCode: 200,
    body: "Hello user!",
  };
}
```

Now let's test our new API.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm start
```

The first time you run this command it'll take a couple of minutes to do the following:

1. It'll bootstrap your AWS environment to use CDK.
2. Deploy a debug stack to power the Live Lambda Development environment.
3. Deploy your app, but replace the functions in the `backend/` directory with ones that connect to your local client.
4. Start up a local client.

Once complete, you should see something like this.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-api-auth-jwt-cognito-user-pool-my-stack: deploying...

 ✅  dev-api-auth-jwt-cognito-user-pool-my-stack


Stack dev-api-auth-jwt-cognito-user-pool-my-stack
  Status: deployed
  Outputs:
    UserPoolClientId: t4gepqqbmbg90dh61pam8rg9r
    UserPoolId: us-east-1_QLBISRQwA
    ApiEndpoint: https://4foju6nhne.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Make a note of the `UserPoolClientId` and `UserPoolId`; we'll need them later.

Now let's try out our public route. Head over to the following in your browser. Make sure to replace the URL with your API.

```
https://4foju6nhne.execute-api.us-east-1.amazonaws.com/public
```

You should see the greeting `Hello stranger!`.

And if you try to visit the private route, you will see `{"message":"Unauthorized"}`.

```
https://4foju6nhne.execute-api.us-east-1.amazonaws.com/private
```

## Sign up with Cognito

Now to visit the private route, we need to create an account in our User Pool. Usually, we'll have our users sign up for an account through our app. But for this example, we'll use the AWS CLI to sign up a user and confirm their account.

Use the following command in your terminal. Replace `--client-id` with `UserPoolClientId` from the `sst start` output above.

```bash
$ aws cognito-idp sign-up \
  --region us-east-1 \
  --client-id t4gepqqbmbg90dh61pam8rg9r \
  --username admin@example.com \
  --password Passw0rd!
```

Next we'll verify the user. Replace `--user-pool-id` with `UserPoolId` from the `sst start` output above.

```bash
$ aws cognito-idp admin-confirm-sign-up \
  --region us-east-1 \
  --user-pool-id us-east-1_QLBISRQwA \
  --username admin@example.com
```

Now we'll authenticate the user. Typically, we'll be using our app to do this. But just to test, we'll use the AWS CLI. Recall we had to enable the `userPassword` authentication flow for this to work. Replace `--client-id` with `UserPoolClientId` from the `sst start` output above.

```bash
$ aws cognito-idp initiate-auth \
  --client-id t4gepqqbmbg90dh61pam8rg9r \
  --auth-flow USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=admin@example.com,PASSWORD=Passw0rd!
```

You should get a set of temporary tokens.

```json
{
  "ChallengeParameters": {},
  "AuthenticationResult": {
    "AccessToken": "eyJraWQiOiI4TUxNTUQzVEJoRHJGdk1pYjBUVXlHMXZmaEZJVnMxRzJTMjNWSlJlaG9rPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI5ZGNlMjY3Ni1lNDAxLTQ2MTMtOTc2Zi03NjIwMThkNGE5MzMiLCJldmVudF9pZCI6ImYwMTdmMWQzLWM5MDAtNGEzOS1hODBiLTNjZTJkMzBiZGUyZSIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4iLCJhdXRoX3RpbWUiOjE2MTQzNzIzNzQsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX1FMQklTUlF3QSIsImV4cCI6MTYxNDM3NTk3NCwiaWF0IjoxNjE0MzcyMzc0LCJqdGkiOiIyNjY0NDdhOS03OTQzLTQxMDUtYjg2YS05YjQ1NmY5NDk0ZjMiLCJjbGllbnRfaWQiOiJ0NGdlcHFxYm1iZzkwZGg2MXBhbThyZzlyIiwidXNlcm5hbWUiOiI5ZGNlMjY3Ni1lNDAxLTQ2MTMtOTc2Zi03NjIwMThkNGE5MzMifQ.RvAQ1u3n0ZcF7D0tKTWJP9Tvr65PwymOkLT3Ob8iZYViop9-RM8YqK-AnHs4SyK7aP8_OgdTIIx4pdbS9ixsgSSu67pQEwXS-2LxCvlDhEQ8UhDc_YxPxeQanKGb6465BYi3UcXzRIIQd7XQO4NHdMxu7i77VkxKoWbDUNGT8qdhx_cUoESZRHkFiW3pT7vDboot_vtHTzCAsNLAlW5fgQgtONxwn3er8AXFYUTTODL8M3MM8kdw-RhxdwT8kFesJvJATmUY-PypfnYXp4zQfhFvBE-eXNXtBMtEpHqmAfFOjFSIhzGh1Jbst6O_xVa7dbT5w_dXGFGmzBLwLCRpxQ",
    "ExpiresIn": 3600,
    "TokenType": "Bearer",
    "RefreshToken": "eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.DLXqfzpikKGjG79Av2aR_Vb-F0Nk6RtZz0lUQ5atuFAo5fB65WneZHpfHcNnps5t4pCYHau7aA26ye9aFnjhkYY1XIrfvdCtctYIpH4Zfhd_pfGPZ7Zmj2GnQyzB9EJmCKKros46ZW78nQuqxgJVctKtFG33TQc7e3DA1nJRlrLBq_mjewFuKqryuaLR0wB5OP5iLCrQjXcVJdCxK499jRR6xEpl-xCEfHnW5eP11T78j7SkgXwQObH1SYY1ZvxyFNP8faLW3Vc9oSqwVpbs4JTLoNmKnVrV0XhSCnOzxIsuGZ22rbMq9hvhez58-IgdCeSx4jGe4oo-DnZmL-vQAw.LoTIKvlPNTrIROzu.YhRdBvDoKGRehOHpWW86wkzYvgEC-fdDrjtOaRO5rw5wvwd23rYu2qJ-M2TaQKHy7cEH4oSW1UxxPbdBo74tF5KRpEIiYTafPIW0_KBL7kMJeGG5uN-x-AWvVmgI4wzzsZnYn_yoG2HAQ-gHPNT8flJftRvqXPi0OGcivoY03rm5OGiqVMDXkwKWhwkllTXmYjOLNx3iIAV1arAZ62JppGmZkKErJy7NFqVoxDt5rEF1bEhZ_cn2Z7S3nnMBdUas-aM7CEYVXDynrckshroO9azZGRTeEJSN-zAy8bTZPbRi26QIGArXZr7bz6qEeDeG5mYgFsi_rpcy169fCmfwaKeVQBn7nWY8eiJ-5aWJ_9tPeKhafbjoKHonuN4Hyr9KRB38bhWgtiDe1kbsQBGkNAjwIe_FD-tIZgZ6FSkqZ-lqionAxZB2Z-hQtaoCofuUki7X12Rxz7t4vfw5Ia4wIylSWMuR4PcuWfCltCYjR1T1IMuXdJsCkTv1hjL5-yqGIBGAwchGGayZTbLwLHJrefAZOPEo9arSPPphQeQNAgK60u5LlBS5bmFMlYGmipqfWhiadtsIPLPfU0DzKEsqtxypeL9d-zpWfylDfEgYrcleOV3o_OoJo1h5Oj09obyjIv038H7McsO376bMoAIKEdPwad84WOZlXbrjf7TEqiwUTNaOMpnrbs_JBp25FfeHpfWvGVALFd1kktu-mQHwzCxqaLxh6nsW3wkFkJiANTJs7KgKF4AJ3i-Mw_XEMKfZnKwocS6q0woxbkTMMfSoVnh56Yjyj4VuuaMoOm4WxMamnXHXOjwYafZ6hkcqA0Sodnns1FY_pkHu_xg6T0gqthJS2yBtJ3vvg4HW6_m-rIa-K26FIoVRtcIr6euPeagzuul2ginD4oGtAETcDVUn3UFTHLjk_OcK1T5hAxyD8sysm7KEOtFQRvdALYBS38qP3FiAjdGbMg5NyKufJO_KGi8LKNALRmW1zSN9DugSnZHhwH1XJ2F7xbWH4kb-bvdt-3DCWU9O2BlYj5OJpggSFSf6GLtpKQ81yTyWzU8-eNq5-bG2tBrlIAq8j9rpG0MNYj0l3MQZb9fwCmDVtjwK1mMywAX2rRhQmAQ2zIdMQVD6SvY7_nbsgA1Zqs_16VslLEPDUOu1XuFGqKINoRwvnocdQY8it_7mKwf1WrTd8EAnOcESzq6T5ViFi3oGhMUtm2GMBuUY9GqRF2gj_O6vdXgJ00gDu2T_ZMIBoNBQawH41G9oyoM_T14thaToHLLQvCwTwlqcD0_MIWGErnFhOpXazGzTF-xiEBuEdzFeGsHpICmzFcYfKQrNzg.W-_nygvWnW5CYurFbxYEAQ",
    "IdToken": "eyJraWQiOiJ4cVFWN0VCWkwrNXpvbUtycHFRYTNSM1F3QzErQ2t4ajRkejhwbEJUbmpJPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI5ZGNlMjY3Ni1lNDAxLTQ2MTMtOTc2Zi03NjIwMThkNGE5MzMiLCJhdWQiOiJ0NGdlcHFxYm1iZzkwZGg2MXBhbThyZzlyIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJldmVudF9pZCI6ImYwMTdmMWQzLWM5MDAtNGEzOS1hODBiLTNjZTJkMzBiZGUyZSIsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNjE0MzcyMzc0LCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV9RTEJJU1JRd0EiLCJjb2duaXRvOnVzZXJuYW1lIjoiOWRjZTI2NzYtZTQwMS00NjEzLTk3NmYtNzYyMDE4ZDRhOTMzIiwiZXhwIjoxNjE0Mzc1OTc0LCJpYXQiOjE2MTQzNzIzNzQsImVtYWlsIjoiYWRtaW5AZXhhbXBsZS5jb20ifQ.m8mf_D5rcxoiUAbKUJIjADqP8M2Oti65I85nYmewGBIefhtSubQkYDI2DhyrYL22LLHvIyxKqcc16XLLR25QFxyZnHwrlF8I1YbDg6zVcudwf_ec00zywclfkoqWao8QYf6KN9XsdUzbYsrVcf91K4gBd4gNLn_okyGGCBB5YH8MBvmnALMNZ3gYvDN1iiP15S7HfToFsWm6bUVE2s7S4kaAZnnBkwl7eZauqn2bWzygfaLCJSCMmS_q663gYLZAq-viLiHZIjB9GOZAH1_Ir3FdcB9l1kSjU1EA2mr6NAQ7UzB0g8E9zfTWrOQ3lZOJnazz3pstGgkVjuCQHw8WAw"
  }
}
```

Let's make a call to the private route using the JWT token. Make sure to replace the token with **IdToken** from the previous step. And the URL with your API endpoint.

```bash
$ curl --url https://4foju6nhne.execute-api.us-east-1.amazonaws.com/private \
  -H "Authorization: Bearer eyJraWQiOiI4TUxNTUQzVEJoRHJGdk1pYjBUVXlHMXZmaEZJVnMxRzJTMjNWSlJlaG9rPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI5ZGNlMjY3Ni1lNDAxLTQ2MTMtOTc2Zi03NjIwMThkNGE5MzMiLCJldmVudF9pZCI6ImYwMTdmMWQzLWM5MDAtNGEzOS1hODBiLTNjZTJkMzBiZGUyZSIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4iLCJhdXRoX3RpbWUiOjE2MTQzNzIzNzQsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX1FMQklTUlF3QSIsImV4cCI6MTYxNDM3NTk3NCwiaWF0IjoxNjE0MzcyMzc0LCJqdGkiOiIyNjY0NDdhOS03OTQzLTQxMDUtYjg2YS05YjQ1NmY5NDk0ZjMiLCJjbGllbnRfaWQiOiJ0NGdlcHFxYm1iZzkwZGg2MXBhbThyZzlyIiwidXNlcm5hbWUiOiI5ZGNlMjY3Ni1lNDAxLTQ2MTMtOTc2Zi03NjIwMThkNGE5MzMifQ.RvAQ1u3n0ZcF7D0tKTWJP9Tvr65PwymOkLT3Ob8iZYViop9-RM8YqK-AnHs4SyK7aP8_OgdTIIx4pdbS9ixsgSSu67pQEwXS-2LxCvlDhEQ8UhDc_YxPxeQanKGb6465BYi3UcXzRIIQd7XQO4NHdMxu7i77VkxKoWbDUNGT8qdhx_cUoESZRHkFiW3pT7vDboot_vtHTzCAsNLAlW5fgQgtONxwn3er8AXFYUTTODL8M3MM8kdw-RhxdwT8kFesJvJATmUY-PypfnYXp4zQfhFvBE-eXNXtBMtEpHqmAfFOjFSIhzGh1Jbst6O_xVa7dbT5w_dXGFGmzBLwLCRpxQ"
```

You should see the greeting `Hello user!`.

## Making changes

Let's make a quick change to our private route to print out the caller's user id.

{%change%} Replace `backend/functions/private.ts` with the following.

```ts
import { APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  return {
    statusCode: 200,
    body: `Hello ${event.requestContext.authorizer.jwt.claims.sub}!`,
  };
};
```

We are getting the user id from the event object.

If you make the same authenticated request to the `/private` endpoint.

```bash
$ curl --url https://4foju6nhne.execute-api.us-east-1.amazonaws.com/private \
  -H "Authorization: Bearer eyJraWQiOiI4TUxNTUQzVEJoRHJGdk1pYjBUVXlHMXZmaEZJVnMxRzJTMjNWSlJlaG9rPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI5ZGNlMjY3Ni1lNDAxLTQ2MTMtOTc2Zi03NjIwMThkNGE5MzMiLCJldmVudF9pZCI6ImYwMTdmMWQzLWM5MDAtNGEzOS1hODBiLTNjZTJkMzBiZGUyZSIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4iLCJhdXRoX3RpbWUiOjE2MTQzNzIzNzQsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX1FMQklTUlF3QSIsImV4cCI6MTYxNDM3NTk3NCwiaWF0IjoxNjE0MzcyMzc0LCJqdGkiOiIyNjY0NDdhOS03OTQzLTQxMDUtYjg2YS05YjQ1NmY5NDk0ZjMiLCJjbGllbnRfaWQiOiJ0NGdlcHFxYm1iZzkwZGg2MXBhbThyZzlyIiwidXNlcm5hbWUiOiI5ZGNlMjY3Ni1lNDAxLTQ2MTMtOTc2Zi03NjIwMThkNGE5MzMifQ.RvAQ1u3n0ZcF7D0tKTWJP9Tvr65PwymOkLT3Ob8iZYViop9-RM8YqK-AnHs4SyK7aP8_OgdTIIx4pdbS9ixsgSSu67pQEwXS-2LxCvlDhEQ8UhDc_YxPxeQanKGb6465BYi3UcXzRIIQd7XQO4NHdMxu7i77VkxKoWbDUNGT8qdhx_cUoESZRHkFiW3pT7vDboot_vtHTzCAsNLAlW5fgQgtONxwn3er8AXFYUTTODL8M3MM8kdw-RhxdwT8kFesJvJATmUY-PypfnYXp4zQfhFvBE-eXNXtBMtEpHqmAfFOjFSIhzGh1Jbst6O_xVa7dbT5w_dXGFGmzBLwLCRpxQ"
```

You should see `Hello 9dce2676-e401-4613-976f-762018d4a933!`.

## Deploying your API

Now that our API is tested and ready to go. Let's go ahead and deploy it for our users. You'll recall that we were using a `dev` environment, the one specified in your `sst.json`.

However, we are going to deploy your API again. But to a different environment, called `prod`. This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

{%change%} Run the following in your terminal.

```bash
$ npm run deploy --stage prod
```

A note on these environments. SST is simply deploying the same app twice using two different `stage` names. It prefixes the resources with the stage names to ensure that they don't thrash.

## Cleaning up

Finally, you can remove the resources created in this example using the following command.

```bash
$ npm run remove
```

And to remove the prod environment.

```bash
$ npm run remove --stage prod
```

## Conclusion

And that's it! You've got a brand new serverless API with a JWT authorizer using Cognito User Pool. A local development environment, to test and make changes. And it's deployed to production as well, so you can share it with your users. Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
