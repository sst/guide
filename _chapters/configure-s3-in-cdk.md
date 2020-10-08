---
layout: post
title: Configure S3 in CDK
date: 2018-02-28 00:00:00
lang: en
description: In this chapter we'll be using AWS CDK to configure a S3 bucket for our Serverless app using the s3.Bucket construct. We'll also be using the Serverless Stack Toolkit (SST) to make sure that we can deploy it alongside our Serverless Framework services.
redirect_from:
  - /chapters/configure-s3-in-serverless.html
  - /chapters/s3-as-a-serverless-service.html
ref: configure-s3-in-cdk
comments_id: configure-s3-in-cdk/2099
---

Now that we have [our DynamoDB table]({% link _chapters/configure-dynamodb-in-cdk.md %}) configured, let's look at how we can configure our S3 file uploads bucket using CDK.

### Create a Stack

{%change%} Add the following to `infrastructure/lib/S3Stack.js`.

``` javascript
import * as cdk from "@aws-cdk/core";
import * as s3 from "@aws-cdk/aws-s3";
import * as sst from "@serverless-stack/resources";

export default class S3Stack extends sst.Stack {
  // Public reference to the S3 bucket
  bucket;

  constructor(scope, id, props) {
    super(scope, id, props);

    this.bucket = new s3.Bucket(this, "Uploads", {
      // Allow client side access to the bucket from a different domain
      cors: [
        {
          maxAge: 3000,
          allowedOrigins: ["*"],
          allowedHeaders: ["*"],
          allowedMethods: ["GET", "PUT", "POST", "DELETE", "HEAD"],
        },
      ],
    });

    // Export values
    new cdk.CfnOutput(this, "AttachmentsBucketName", {
      value: this.bucket.bucketName,
    });
  }
}
```

If you recall from the [Create an S3 bucket for file uploads]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) chapter, we had created a bucket and configured the CORS policy for it. The CORS policy is necessary because we are uploading directly from our frontend client. We'll configure the same policy here.

Just like the DynamoDB stack that [we created in the last chapter]({% link _chapters/configure-dynamodb-in-cdk.md %}), we are going to output the name of the bucket that we created. However, we don't need to create a CloudFormation export because we need this value in our React app. And there isn't really a way to import CloudFormation exports there.

The one thing that we are doing differently here is that we are creating a public class property called `bucket`. It holds a reference to the bucket that is created in this stack. We'll refer to this later when [creating our Cognito IAM policies]({% link _chapters/configure-cognito-identity-pool-in-cdk.md %}).

You can refer to the CDK docs for more details on the [**s3.Bucket**](https://docs.aws.amazon.com/cdk/api/latest/docs/@aws-cdk_aws-s3.Bucket.html) construct.

{%change%} Let's add the S3 CDK package. Run the following in your `infrastructure/` directory.

``` bash
$ npx sst add-cdk @aws-cdk/aws-s3
```

This will do an `npm install` using the right CDK version.

### Add the Stack

{%change%} Let's add this stack to our CDK app. Replace your `infrastructure/lib/index.js` with this.

``` javascript
import S3Stack from "./S3Stack";
import DynamoDBStack from "./DynamoDBStack";

// Add stacks
export default function main(app) {
  new DynamoDBStack(app, "dynamodb");

  new S3Stack(app, "s3");
}
```

### Deploy the Stack

{%change%} Now let's deploy our new stack by running the following from the `infrastructure/` directory.

``` bash
$ npx sst deploy
```

You should see something like this at the end of your deploy output.

``` bash
Stack dev-notes-infra-s3
  Status: deployed
  Outputs:
    AttachmentsBucketName: dev-notes-infra-s3-uploads4f6eb0fd-18yd4altuql9g
```

You'll notice the output has the name of our newly created S3 bucket.

And that's it. Next let's look into configuring our Cognito User Pool.
