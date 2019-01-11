---
layout: post
title: What is an ARN
date: 2016-12-25 20:00:00
lang: en
ref: what-is-an-arn
description: Amazon Resource Names (or ARNs) uniquely identify AWS resources. It is a globally unique identifier and follows a couple of pre-defined formats. ARNs are used primarily for communicating the reference to a resource and for defining IAM policies.
context: true
comments_id: what-is-an-arn/34
---

In the last chapter while we were looking at IAM policies we looked at how you can specify a resource using its ARN. Let's take a better look at what ARN is.

Here is the official definition:

> Amazon Resource Names (ARNs) uniquely identify AWS resources. We require an ARN when you need to specify a resource unambiguously across all of AWS, such as in IAM policies, Amazon Relational Database Service (Amazon RDS) tags, and API calls.

ARN is really just a globally unique identifier for an individual AWS resource. It takes one of the following formats.

```
arn:partition:service:region:account-id:resource
arn:partition:service:region:account-id:resourcetype/resource
arn:partition:service:region:account-id:resourcetype:resource
```

Let's look at some examples of ARN. Note the different formats used.

```
<!-- Elastic Beanstalk application version -->
arn:aws:elasticbeanstalk:us-east-1:123456789012:environment/My App/MyEnvironment

<!-- IAM user name -->
arn:aws:iam::123456789012:user/David

<!-- Amazon RDS instance used for tagging -->
arn:aws:rds:eu-west-1:123456789012:db:mysql-db

<!-- Object in an Amazon S3 bucket -->
arn:aws:s3:::my_corporate_bucket/exampleobject.png
```

Finally, let's look at the common use cases for ARN.

1. Communication

   ARN is used to reference a specific resource when you orchestrate a system involving multiple AWS resources. For example, you have an API Gateway listening for RESTful APIs and invoking the corresponding Lambda function based on the API path and request method. The routing looks like the following.

   ```
   GET /hello_world => arn:aws:lambda:us-east-1:123456789012:function:lambda-hello-world
   ```

2. IAM Policy

   We had looked at this in detail in the last chapter but here is an example of a policy definition.

   ``` json
   {
     "Version": "2012-10-17",
     "Statement": {
       "Effect": "Allow",
       "Action": ["s3:GetObject"],
       "Resource": "arn:aws:s3:::Hello-bucket/*"
   }
   ```
   
   ARN is used to define which resource (S3 bucket in this case) the access is granted for. The wildcard `*` character is used here to match all resources inside the *Hello-bucket*.

Next let's configure our AWS CLI. We'll be using the info from the IAM user account we created previously.
