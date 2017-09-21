---
layout: post
---

### What to log

There are 2 types of logs we usually take for granted in the monolithic environment.

- Server log

  Web server log maintains a history of page requests, in the order they took place. Each log entry contains the information about the request, including client IP address, request date/time, request path, HTTP code, bytes served, user agent, etc.

- Application log

  Applicaiton log is a file of events that are logged by the web application. It usually contains errors, warnings and informational events. It could contain everything from unexpected function failure, to key events for understanding how users behave.


In the serverless environment, we have lesser control over the underlying infrastructure, logging is the only way to acquire knowledge on how the application is performing. Amazon CloudWatch is a monitoring service to help you collect and track metrics for your resources. We are going to look at how to enable logging for API Gateway and Lambda.


### Enable API Gateway Log

This is a two step process. First, we need to create an IAM role that allows API Gateway to write logs in CloudWatch. Then we need to turn on logging for our API project.

First, log in to your [AWS Console](https://console.aws.amazon.com) and select IAM from the list of services.

![Select IAM Service Screenshot]({{ site.url }}/assets/logging/select-iam-service.png)

Select **Roles** on the left menu

![Select IAM Roles Screenshot]({{ site.url }}/assets/logging/select-iam-roles.png)

Select **Create Role**

![Select Create IAM Role Screenshot]({{ site.url }}/assets/logging/select-create-iam-role.png)

Under **AWS service**, select **API Gateway**.

![Select API Gateway IAM Role Screenshot]({{ site.url }}/assets/logging/select-api-gateway-iam-role.png)

Select **Next: Permissions**.

![Select IAM Role Attach Permissions Screenshot]({{ site.url }}/assets/logging/select-iam-role-attach-permissions.png)

Select **Next: Review**

![Select Review IAM Role Screenshot]({{ site.url }}/assets/logging/select-review-iam-role.png)

Enter a **Role name** and select **Create role**.

![Fill in IAM Role Info Screenshot]({{ site.url }}/assets/logging/fill-in-iam-role-info.png)

Click on the role we just created

![Select Created API Gateway IAM Role Screenshot]({{ site.url }}/assets/logging/select-created-api-gateway-iam-role.png)

Take a note of the **Role ARN**, which will be needed in the later step.

![IAM Role ARN Screenshot]({{ site.url }}/assets/logging/iam-role-arn.png)

Now, go back to your [AWS Console](https://console.aws.amazon.com) and select API Gateway from the list of services.

![Select API Gateway Service Screenshot]({{ site.url }}/assets/logging/select-api-gateway-service.png)

Select **Settings** from the left panel

![Select API Gateway Settings Screenshot]({{ site.url }}/assets/logging/select-api-gateway-settings.png)

Enter the ARN of the IAM role we just created in **CloudWatch log role ARN**, then select **Save**

![Fill in API Gateway CloudWatch Info Screenshot]({{ site.url }}/assets/logging/fill-in-api-gateway-cloudwatch-info.png)

Select your API project from the left panel, select **Stages**, then pick the stage you want to enable logging for.

![Select API Gateway Stage Screenshot]({{ site.url }}/assets/logging/select-api-gateway-stage.png)

In the **Settings** tab,

- Check **Enable CloudWatch Logs**.
- Select **INFO** for **Log level** to log every requests.
- Check **Log full requests/responses data** to include entire request and response body in the log.
- Check **Enable Detailed CloudWatch Metrics** to track latencies and errors in CloudWatch metrics.

![Fill in API Gateway Logging Info Screenshot]({{ site.url }}/assets/logging/fill-in-api-gateway-logging-info.png)

Scroll to the bottom of the page and click **Save Changes**.

![Update API Gateway Logging Screenshot]({{ site.url }}/assets/logging/update-api-gateway-logging.png)


### Enable Lambda Log

Lambda logs are enabled by default. It tracks the duration and max memory usage for each execution. You can write additional information to CloudWatch via `console.log`. For example:

``` javascript
export function main(event, context, callback) {
  console.log('Hello world');
  callback(null, { body: '' });
}
```

### View Logs

CloudWatch groups log entries into **Log Groups** and then further into **Log Streams**. Log Groups and Log Streams can mean different things for different AWS services. For API Gateway, when logging is first enabled in an API project's stage, API Gateway creates 1 log group for the stage, and 300 log streams in the group ready to store log entries. Upon an incoming http request, a stream is picked by API Gateway.

To view API Gateway logs, log in to your [AWS Console](https://console.aws.amazon.com) and select CloudWatch from the list of services.

![Select CloudWatch Service Screenshot]({{ site.url }}/assets/logging/select-cloudwatch-service.png)

Select **Logs** from the left panel.

![Select CloudWatch Logs Screenshot]({{ site.url }}/assets/logging/select-cloudwatch-logs.png)

Select the log group prefixed with **API-Gateway-Execution-Logs_** followed by the API Gateway id.

![Select CloudWatch API Gateway Log Group Screenshot]({{ site.url }}/assets/logging/select-cloudwatch-api-gateway-log-group.png)

You should see 300 log streams order by the last event time, which is the last request time recorded. Select the first stream.

![Select CloudWatch API Gateway Log Stream Screenshot]({{ site.url }}/assets/logging/select-cloudwatch-api-gateway-log-stream.png)

You should see log entries grouped by request. Note two consecutive groups of logs are not necessarily consecutive requests in real time, as there might be other requests in between that are logged in other streams.

![CloudWatch API Gateway Log Entries Screenshot]({{ site.url }}/assets/logging/cloudwatch-api-gateway-log-entries.png)


For Lambda, each function has its own log group. And the log stream rotates when a new version of a Lambda function is deployed, and when a function is idle for some time.

To view Lambda logs, select **Logs** again from the left panel. Then select the first log group prefixed with **/aws/lambda/** followed by the function name.

![Select CloudWatch Lambda Log Group Screenshot]({{ site.url }}/assets/logging/select-cloudwatch-lambda-log-group.png)

Select the first stream.

![Select CloudWatch Lambda Log Stream Screenshot]({{ site.url }}/assets/logging/select-cloudwatch-lambda-log-stream.png)

You should see **START**, **END** and **REPORT** with basic execution information for each function invokation. You can also see content logged via `console.log` in your Lambda code.

![CloudWatch Lambda Log Entries Screenshot]({{ site.url }}/assets/logging/cloudwatch-lambda-log-entries.png)
