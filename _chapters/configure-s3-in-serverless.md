---
layout: post
title: Configure S3 in Serverless
date: 2018-02-28 00:00:00
lang: en
description: We can define our S3 Buckets using the Infrastructure as Code pattern by using CloudFormation in our serverless.yml. We are going to set the CORS policy and output the name of the bucket that's created.
ref: configure-s3-in-serverless
comments_id: configure-s3-in-serverless/163
---

Now that we have DynamoDB configured, let's look at how we can configure the S3 file uploads bucket through our `serverless.yml`.

### Create the Resource

<img class="code-marker" src="/assets/s.png" />Add the following to `resources/s3-bucket.yml`.

``` yml
Resources:
  AttachmentsBucket:
    Type: AWS::S3::Bucket
    Properties:
      # Set the CORS policy
      CorsConfiguration:
        CorsRules:
          -
            AllowedOrigins:
              - '*'
            AllowedHeaders:
              - '*'
            AllowedMethods:
              - GET
              - PUT
              - POST
              - DELETE
              - HEAD
            MaxAge: 3000

# Print out the name of the bucket that is created
Outputs:
  AttachmentsBucketName:
    Value:
      Ref: AttachmentsBucket
```

If you recall from the [Create an S3 bucket for file uploads]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) chapter, we had created a bucket and configured the CORS policy for it. We needed to do this because we are going to be uploading directly from our frontend client. We configure the same policy here.

S3 buckets (unlike DynamoDB tables) are globally named, so it is not really possible for us to know what our bucket is going to be called beforehand. Hence, we let CloudFormation generate the name for us and we just add the `Outputs:` block to tell it to print it out so we can use it later.

### Add the Resource

<img class="code-marker" src="/assets/s.png" />Let's reference the resource in our `serverless.yml`. Replace your `resources:` block with the following.

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # API Gateway Errors
  - ${file(resources/api-gateway-errors.yml)}
  # DynamoDB
  - ${file(resources/dynamodb-table.yml)}
  # S3
  - ${file(resources/s3-bucket.yml)}
```

And that's it. Next let's look into configuring our Cognito User Pool.
