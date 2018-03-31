---
layout: post
title: Configure S3 in Serverless
date: 2017-05-30 00:00:00
description:
comments_id:
---

Now that we have DynamoDB configured, let's look at how we can configure the S3 file uploads bucket through our `serverless.yml`.

### Add the resource

Add the following to `resources/s3-bucket.yml`.

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

S3 buckets (unlike DynamoDB tables) are globally named. So it is not really possible for us to know what it going to be called before hand. Hence, we let CloudFormation generate the name for us and we just add the `Outputs:` block to tell it to print it out so we can use it later.

### Add resource to serverless.yml

Let's reference the resource in our `serverless.yml` by adding the following line in the `resources:`. So it should now look something like this:

``` yml
# Create our resources with separate CloudFormation templates
resources:
  # DynamoDB
  - ${file(resources/dynamodb-table.yml)}
  # S3
  - ${file(resources/s3-bucket.yml)}
```

### Commit your code

Let's commit the changes we've made so far.

``` bash
$ git add .
$ git commit -m "Adding our S3 resource"
```

And that's it. Next let's look into configuring our Cognito User Pool.
