---
layout: post
title: Debugging Serverless API Issues
description: Debugging serverless APIs can be tricky because there isn’t enough visibility on all the steps a request goes through. A very common issue is an invalid or missing IAM Role while using aws_iam as an authorizer for API Gateway and Lambda. To fix this use the Policy Simulator to ensure that your IAM Role has access to API Gateway.
date: 2018-04-04 00:00:00
comments_id: debugging-serverless-api-issues/143
---

In this chapter we are going to take a brief look at some common API Gateway and Lambda issues we come across and how to debug them.

We've also compiled a list of some of the most common Serverless errors over on [Seed](https://seed.run). Check out [Common Serverless Errors](https://seed.run/docs/serverless-errors/) and do a quick search for your error message and see if it has a solution.

When a request is made to your serverless API, it starts by hitting API Gateway and makes its way through to Lambda and invokes your function. It takes quite a few hops along the way and each hop can be a point of failure. And since we don't have great visibility over each of the specific hops, pinpointing the issue can be a bit tricky. We are going to take a look at the following issues:

- [Invalid API Endpoint](#invalid-api-endpoint)
- [Missing IAM Policy](#missing-iam-policy)
- [Lambda Function Error](#lambda-function-error)
- [Lambda Function Timeout](#lambda-function-timeout)

This chapter assumes you have turned on CloudWatch logging for API Gateway and that you know how to read both the API Gateway and Lambda logs. If you have not done so, start by taking a look at the chapter on [API Gateway and Lambda Logs]({% link _chapters/api-gateway-and-lambda-logs.md %}).


### Invalid API Endpoint

The first and most basic issue we see is when the API Gateway endpoint that is requested is invalid. An API Gateway endpoint usually looks something like this:

```
https://API_ID.execute-api.REGION.amazonaws.com/STAGE/PATH
```

- **API_ID** - a unique identifier per API Gateway project
- **REGION** - the AWS region in which the API Gateway project is deployed to
- **STAGE** - the stage of the project (defined in your **serverless.yml** or passed in through the **serverless deploy --stage** command)
- **PATH** - the path of an API endpoint (defined in your **serverless.yml** for each function)

An API request will fail if:

- The **API_ID** is not found in the specified **REGION**
- The API Gateway project does not have the specified **STAGE**
- API endpoint invoked does not match a pre-defined **PATH**

In all of these cases, the error does not get logged to CloudWatch since the request does not hit your API Gateway project.


### Missing IAM Policy

This happens when your API endpoint uses **aws_iam** as the authorizer, and the IAM role 
assigned to the Cognito Identity Pool has not been granted the **execute-api:Invoke** permission for your API Gateway resource.

This is a tricky issue to debug because the request still has not reached API Gateway, and hence the error is not logged in the API Gateway CloudWatch logs. But we can perform a check to ensure that our Cognito Identity Pool users have the required permissions, using the [IAM policy Simulator](https://policysim.aws.amazon.com).

Before we can use the simulator we first need to find out the name of the IAM role that we are using to connect to API Gateway. We had created this role back in the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter.

Select **Cognito** from your [AWS Console](https://console.aws.amazon.com).

![Select Cogntio Service Screenshot](/assets/debugging/select-cognito-screenshot.png)

Next hit the **Manage Federated Identities** button.

![Click Manage Federated Identities Screenshot](/assets/debugging/click-manage-federated-identities-screenshot.png)

And select your Identity Pool. In our case it's called `notes identity pool`.

![Select identity pool Screenshot](/assets/debugging/select-identity-pool-screenshot.png)

Click **Edit identity pool** at the top right.

![Click Edit identity pool Screenshot](/assets/debugging/click-edit-identity-pool-screenshot.png)

Here make a note of the name of the **Authenticated role**. In our case it is `Cognito_notesidentitypoolAuth_Role`.

![Identity Pool Auth Role Screenshot](/assets/debugging/identity-pool-auth-role-screenshot.png)

Now that we know the IAM role we are testing, let's open up the [IAM Policy Simulator](https://policysim.aws.amazon.com).

![Open IAM Policy Simulator](/assets/debugging/open-iam-policy-simulator.png)

Select **Roles**.

![Select IAM Service Simulator Roles](/assets/debugging/select-iam-policy-simulator-roles.png)

Select the IAM role that we made a note of in the steps above. In our case it is `Cognito_notesidentitypoolAuth_Role`.

![Select IAM Service Simulator Role](/assets/debugging/select-iam-policy-simulator-role.png)

Select **API Gateway** as the service and select the **Invoke** action.

![Select IAM Service Simulator Action](/assets/debugging/select-iam-policy-simulator-action.png)

Expand the service and enter the API Gateway endpoint ARN, then select **Run Simulation**. The format here is the same one we used back in the [Create a Cognito identity pool]({% link _chapters/create-a-cognito-identity-pool.md %}) chapter; `arn:aws:execute-api:YOUR_API_GATEWAY_REGION:*:YOUR_API_GATEWAY_ID/*`. In our case this looks like `arn:aws:execute-api:us-east-1:*:ly55wbovq4/*`.

![Enter API Gateway Endpoint ARN](/assets/debugging/enter-api-gateway-endpoint-arn.png)

If your IAM role is configured properly you should see **allowed** under **Permission**.

![IAM Service Simulator Permission Allowed](/assets/debugging/iam-policy-simulator-permission-allowed.png)

But if something is off, you'll see **denied**.

![IAM Service Simulator Permission Denied](/assets/debugging/iam-policy-simulator-permission-denied.png)

To fix this and edit the role we need to go back to the [AWS Console](https://console.aws.amazon.com) and select IAM from the list of services.

![Select IAM Service Screenshot](/assets/debugging/select-iam-service.png)

Select **Roles** on the left menu.

![Select IAM Roles Screenshot](/assets/debugging/select-iam-roles.png)

And select the IAM role that our Identity Pool is using. In our case it's called `Cognito_notesidentitypoolAuth_Role`.

![Select notes identity pool auth role Screenshot](/assets/debugging/select-notes-identity-pool-auth-role.png)

Expand the policy under the list of policies.

![Expand auth role policy Screenshot](/assets/debugging/expand-auth-role-policy.png)

Click **Edit policy**.

![Edit auth role policy Screenshot](/assets/debugging/edit-auth-role-policy.png)

Here you can edit the policy to ensure that it has the right permission to invoke API Gateway. Ensure that there is a block in your policy like the one below.

``` coffee
...
    {
      "Effect": "Allow",
      "Action": [
        "execute-api:Invoke"
      ],
      "Resource": [
        "arn:aws:execute-api:YOUR_API_GATEWAY_REGION:*:YOUR_API_GATEWAY_ID/*"
      ]
    }
...
```

Finally, hit **Save** to update the policy.

![Save auth role policy Screenshot](/assets/debugging/save-auth-role-policy.png)

Now if you test your policy, it should show that you are allowed to invoke your API Gateway endpoint.


### Lambda Function Error

Now if you are able to invoke your Lambda function but it fails to execute properly due to uncaught exceptions, it'll error out. These are pretty straightforward to debug. When this happens, AWS Lambda will attempt to convert the error object to a string, and then send it to CloudWatch along with the stacktrace. This can be observed in both Lambda and API Gateway CloudWatch log groups.


### Lambda Function Timeout

Sometimes we might run into a case where the Lambda function just times out. Normally, a Lambda function will end its execution by invoking the **callback** function that was passed in. By default, the callback will wait until the Node.js runtime event loop is empty before returning the results to the caller. If the Lambda function has an open connection to, let's say a database server, the event loop is not empty, and the callback will wait indefinitely until the connection is closed or the Lambda function times out.

To get around this issue, you can set this **callbackWaitsForEmptyEventLoop** property to false to request AWS Lambda to freeze the process as soon as the callback is called, even if there are events in the event loop.

``` javascript
export async function handler(event, context, callback) {

  context.callbackWaitsForEmptyEventLoop = false;
  
  ...
};
```

This effectively allows a Lambda function to return its result to the caller without requiring that the database connection be closed. This allows the Lambda function to reuse the same connection across calls, and it reduces the execution time as well.


These are just a few of the common issues we see folks running into while working with serverless APIs. Feel free to let us know via the comments if there are any other issues you'd like us to cover.
