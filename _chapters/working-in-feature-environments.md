---
layout: post
title: Working in feature environments
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

After commiting the initial version of code to the `like` branch, you are going to keep working on it. A common problem people running into is `sls deploy` takes very long to execute. And running `sls deploy` for each small change just takes very long.

# Why is 'sls deploy' slow?

When you run `sls deploy`, Serverless Framework does two things:

- packages the Lambda code into zip files; and
- builds a CloudFormation template with all the resources defined in `serverless.yml`

The code is uploaded to S3 and the template is submitted to CloudFormation.

There are a couple of things that are causing the slowness here:

1. When working on a feature, most of the changes are code changes. It is not necessary to rebuild the CloudFormation template and submitting it to CloudFormation to update the resources.
2. When making a code change, a lot of the time you are changing 1 Lambda function at a time. When that is the case, it is not necessary to re-package the code for all Lambda functions in the service.

# Deploy individual function

Fortunately,  there is a way to deploy individual functions via `sls deploy -f`. Let's take a look at an example.

Say we want to cap the number of recommendations returned to 6 items. Change the code to:
``` javascript
'use strict';

module.exports.main = (event, context, callback) => {
  const recommendations = [
    // Add fancy machine learning code here
  ];

  callback(null, {
    statusCode: 200,
    body: JSON.stringify(recommendations.slice(0, 6)),
  });                   
};
```
To deploy the code for this function, run:
``` bash
$ cd services/like-api
$ sls deploy -f like -s like
```
Deploying an individual function should be much quicker than deploying the entire stack.

# Deploy multiple functions

 Sometimes a code change can affect multiple functions at the same time. For example, if you changed a shared library, you have to re-deploy all the services importing the library.

However, there isn't a convenient way to deploy multiple Lambda functions. If you can easily tell which Lambda functions are affected, deploy each functions individually. If there are many functions are involved, run `sls deploy -s like` to deploy all functions, just to be on the safe size.
