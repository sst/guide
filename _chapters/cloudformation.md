---
layout: post
---

### What is CloudFormation?

AWS CloudFormation is a service that helps you model and set up your Amazon Web Services resources. You create a template that describes all the AWS resources that you want (like Lambda functions, API Gateway endpoints or DynamoDB tables), and AWS CloudFormation takes care of provisioning and configuring those resources for you. You don't need to go to the AWS management console and individually create and configure AWS resources and figure out what's dependent on what; AWS CloudFormation handles all of that.

Another added benefit is that your CloudFormation template is reusable. Imagine you have a production service has an API Gateway endpoint listening to user requets; Lambda functions processing the requests; DynamoDB storing the user information. Now, if you want to create a development environment to test your new code before hitting production, you will have to replicate all the resources.

When you use AWS CloudFormation, you can reuse your template to set up your resources consistently and repeatedly. Just describe your resources once and then provision the same resources over and over in multiple regions.

In fact, Serverless Framework uses CloudFormation internally.


### Provision resources in serverless.yml

Upon deploying, Serverless Framework translates `serverless.yml` into CloudFormation template and then hands it off to CloudFormation to update the resources. Here is an example,

```
service: service-name

provider:
  name: aws
  stage: dev

functions:
  hello:
    handler: handler.hello
    events:
      - http:
          path: hello
          method: get
```

Serverless Framework creates following resources:
- an S3 bucket to store the code for `handler.js`
- a Lambda function with code source pointing to the S3 bucket
- an IAM role granting access to AWS resources (ie. CloudWatch) for Lambda function to assume
- an API Gateway project
- an API Gateway stage `dev`
- an API Gateway method routing GET request to /hello to the Lambda function

If you want Serverless Framework to provision additional resources when running `serverless deploy`, you can define them in CloudFormation syntax and simply add them to the `resources` section of `serverless.yml`. Here is an example that creates an S3 bucket upon deploying:

```
service: service-name

provider:
  name: aws
  stage: dev

functions:
  hello:
    handler: handler.hello
    events:
      - http:
          path: hello
          method: get

resources:
  Resources:
    MyS3Bucket:
      Type: AWS::S3::Bucket
```

In the resources, we simply defined an AWS resource of the type S3 bucket. You can also create a DynamoDB table with type `AWS::DynamoDB::Table`, a Cognito user pool with type `AWS::Cognito::UserPool`, etc.

[http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html] has a full list with examples for all resources you can provision via CloudFormation.

Upon deploying, Serverless Framework simply merges the `resources` section with the CloudFormation template it generates.
