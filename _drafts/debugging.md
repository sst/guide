---
layout: post
---

When a user makes a request to your API endpoint, from the moment AWS receives the request all the way to the request reaching your Lambda function, the request goes through many hops. Each hop being a point of failure, it can tricky to pin point where the issue is. In this chapter we are going to examine some common issues.

This chapter assumes you have turned on CloudWatch logging for API Gateway. If you have not done so, read the **logging** chapter first.


### Invalid API endpoint

An API Gateway endpoint usually looks like

```
https://API_ID.execute-api.REGION.amazonaws.com/STAGE/PATH
```

- **API_ID** a unique identifier per API Gateway project
- **REGION** the AWS region in which the API Gateway project deployed to
- **STAGE** the stage of the project, which is defined in your **serverless.yml** or passed to the **serverless deploy** command
- **PATH** the path of an API endpoint, which is also defined in your **serverless.yml** for each function

When an API endpoint is invoked, if the API ID is not found in the specified region; or if the API project does not have the specified stage; or if the API endpoint that is invoked does not match a pre-defined path, the API call will fail. And the error does not get logged in CloudWatch, as the request did not reached API Gateway.


### Missing IAM policy

This happens when your API endpoint uses **aws_iam** as the authorizer, and the IAM role 
assigned to the Cognito Identity Pool was not granted the **execute-api:Invoke** permission to your API Gateway resource.

This is a tricky issue to debug because the request still has not reached API Gateway, and hence the error is not logged in the API Gateway logs. You can perform a quick sanity check to ensure your Cognito Identity Pool users have required permissions via the IAM policy simulator.

Open [IAM Policy Simulator](https://policysim.aws.amazon.com).

![Open IAM Policy Simulator](/assets/debugging/open-iam-policy-simulator.png)

Select **Roles**.

![Select IAM Service Simulator Roles](/assets/debugging/select-iam-policy-simulator-roles.png)

Select the IAM role assigned to the Cognito Identity Pool. To look up the name of the IAM role, refer to the [Create a Cognito identity pool](/chapters/create-a-cognito-identity-pool.html) chapter and identify the **Authenticated role** name of the Cognito Identity Pool.

![Select IAM Service Simulator Role](/assets/debugging/select-iam-policy-simulator-role.png)

Select the **API Gateway** service and the **Invoke** action.

![Select IAM Service Simulator Action](/assets/debugging/select-iam-policy-simulator-action.png)

Expand the service and enter the API Gateway endpoint ARN, then select **Run Simulation**.

![Enter API Gateway Endpoint ARN](/assets/debugging/enter-api-gateway-endpoint-arn.png)

You should see **allowed** under **Permission**.

![IAM Service Simulator Permission Allowed](/assets/debugging/iam-policy-simulator-permission-allowed.png)

In the case permission is not granted, you will see **denied**.

![IAM Service Simulator Permission Denied](/assets/debugging/iam-policy-simulator-permission-denied.png)

To grant the permission, recall the [Create a Cognito identity pool](/chapters/create-a-cognito-identity-pool.html) chapter. The IAM policy assigned to the Cognito Identity Pool include

``` json
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


### Lambda function error out

This happens if the Lambda function fails to execute properly due to uncaught exceptions. When this happens, AWS Lambda will attemp to convert the error object to a Strin, and then send it to CloudWatch along with the stacktrace. This is very straight forward to debug as the error can be observed in both Lambda and API Gateway CloudWatch log group.


### Lambda function timeout

Normally, a Lambda function will end its execution by invoking the **callback** function that was passed in. By default, the callback will wait until the Node.js runtime event loop is empty before returning the results to the caller. If the Lambda function has an open connection to, per se a database server, the event loop is not empty, and the callback will wait indefinitely until the connection is closed or the Lambda function times out.

To get around this issue, you can set this **callbackwaitsforemptyeventloop** property to false to request AWS Lambda to freeze the process soon after the callback is called, even if there are events in the event loop.

``` javascript
export async function handler(event, context, callback) {

  context.callbackwaitsforemptyeventloop = false;
  
  ...
};
```

This effectively allows a Lambda function to return its result to the caller without requiring that the database connection be closed. This allows the Lambda function to reuse the same connection across calls, and reduce the execution time.
