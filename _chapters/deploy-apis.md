---
layout: post
title: Deploy APIs
---

### Deploy

Update serverless.yml file and paste the following code


In **iamRoleStatements**, we defined the permission policy for the code. For example, in this tutorial, the code needs access to DyanmoDB.

In **functions**: we defined 1 http endpoint with path **/notes**. We enabled CORS (Cross-Origin Resource Sharing) for browswer cross domain api call. The api is authencated via the user pool we created in the previous tutorial. **us-east-1_WdHEGAi8O** is your user pool id.

{% highlight yaml %}
service: notes-app-api

provider:
  name: aws
  runtime: nodejs4.3
  stage: prod
  region: us-east-1

  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:DescribeTable
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      Resource: "arn:aws:dynamodb:us-east-1:*:*"

functions:
  list:
    handler: list.list
    events:
      - http:
          path: notes
          method: get
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O

  get:
    handler: get.get
    events:
      - http:
          path: notes/{id}
          method: get
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O

  create:
    handler: create.create
    events:
      - http:
          path: notes
          method: post
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O

  update:
    handler: update.update
    events:
      - http:
          path: notes/{id}
          method: put
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O

  delete:
    handler: delete.delete
    events:
      - http:
          path: notes/{id}
          method: delete
          request:
            parameters:
              paths:
                id: true
          cors: true
          authorizer:
            arn: arn:aws:cognito-idp:us-east-1:232771856781:userpool/us-east-1_WdHEGAi8O
{% endhighlight %}

Deploy!

{% highlight bash %}
$ serverless deploy
{% endhighlight %}

