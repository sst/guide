---
layout: post
title: Why Create Serverless Apps?
date: 2016-12-24 00:00:00
lang: en
ref: why-create-serverless-apps
description: Serverless apps are easier to maintain and scale, since the resources necessary to complete a request is fully managed by the cloud provider. Serverless apps are also billed only when they are actually in use; meaning that they can be a lot cheaper for most common workloads.
comments_id: why-create-serverless-apps/87
---

It is important to address why it is worth learning how to create serverless apps. There are a few reasons why serverless apps are favored over traditional server hosted apps:

1. Low maintenance
2. Low cost
3. Easy to scale

The biggest benefit by far is that you only need to worry about your code and nothing else. The low maintenance is a result of not having any servers to manage. You don't need to actively ensure that your server is running properly, or that you have the right security updates on it. You deal with your own application code and nothing else.

The main reason it's cheaper to run serverless applications is that you are effectively only paying per request. So when your application is not being used, you are not being charged for it. Let's do a quick breakdown of what it would cost for us to run our note taking application. We'll assume that we have 1000 daily active users making 20 requests per day to our API, and storing around 10MB of files on S3. Here is a very rough calculation of our costs.

{: .cost-table }
| Service             | Rate          | Cost  |
| ------------------- | ------------- | -----:|
| Cognito             | Free<sup>[1]</sup> | $0.00 |
| API Gateway         | $3.5/M reqs + $0.09/GB transfer | $2.20 |
| Lambda              | Free<sup>[2]</sup> | $0.00 |
| DynamoDB            | $0.0065/hr 10 write units, $0.0065/hr 50 read units<sup>[3]</sup> | $2.80 |
| S3                  | $0.023/GB storage, $0.005/K PUT, $0.004/10K GET, $0.0025/M objects<sup>[4]</sup> | $0.24 |
| CloudFront          | $0.085/GB transfer + $0.01/10K reqs | $0.86 |
| Route53             | $0.50 per hosted zone + $0.40/M queries | $0.50 |
| Certificate Manager | Free | $0.00 |
| **Total** | | **$6.10** |

[1] Cognito is free for < 50K MAUs and $0.00550/MAU onwards.  
[2] Lambda is free for < 1M requests and 400000GB-secs of compute.  
[3] DynamoDB gives 25GB of free storage.  
[4] S3 gives 1GB of free transfer.  

So that comes out to $6.10 per month. Additionally, a .com domain would cost us $12 per year, making that the biggest up front cost for us. But just keep in mind that these are very rough estimates. Real-world usage patterns are going to be very different. However, these rates should give you a sense of how the cost of running a serverless application is calculated.

Finally, the ease of scaling is thanks in part to DynamoDB which gives us near infinite scale and Lambda that simply scales up to meet the demand. And of course our front end is a simple static single page app that is almost guaranteed to always respond instantly thanks to CloudFront.

Great! Now that you are convinced on why you should build serverless apps; let's get started.
