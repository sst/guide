---
layout: post
title: Creating feature environments
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

Beside Lambda and API Gateway, your project will have other AWS services. To run your code locally, you have to simulate the AWS services. Similar to `serverless-offline` simulates API Gateway, there are plugins like `serverless-dynamodb-local` and `serverless-offline-sns` that can simulate DynamoDB and SNS. However, mocking only takes you so far since they do not simulate IAM permission and they are not always updated with the services' latest changes. You want to test your code on real resources asap.

Let's add a new feature that lets you like a note. We will add a new API endpoint `/notes/{id}/like`, let's take a look at what our feature branch workflow looks like.

# Enable Branch workflow on Seed

Go to your app on Seed. Select **Settings**.

![](/assets/best-practices/creating-pull-request-environments-1.png)

Scroll down to **Git Integration**. Then select **Enable Auto-Deploy Branches**.

![](/assets/best-practices/creating-pull-request-environments-2.png)

Select **Enable**.

![](/assets/best-practices/creating-pull-request-environments-3.png)

# Add business logic code

We will create a new feature branch `like`.
``` bash
$ git checkout -b like
```
Create the `like-api` service.
``` bash
$ cd services
$ mkdir like-api
$ cd like-api
```
Add a `serverless.yml`
``` yaml
service: notes-app-mono-like-api

plugins:
  - serverless-bundle
  - serverless-offline

custom:
  # Our stage is based on what is passed in when running serverless
  # commands. Or fallsback to what we have set in the provider section.
  stage: ${opt:stage, self:provider.stage}

package:
  individually: true

provider:
  name: aws
  runtime: nodejs10.x
  stage: dev
  region: us-east-1
  tracing:
    lambda: true

  apiGateway:
    restApiId:
      'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiId
    restApiRootResourceId:
      'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiRootResourceId
    restApiResources:
      /notes/{id}:
        'Fn::ImportValue': ${self:custom.stage}-ApiGatewayResourceNotesIdVarId

  environment:
    stage: ${self:custom.stage}

  iamRoleStatements:
    - ${file(../../serverless.common.yml):lambdaPolicyXRay}

functions:
  like:
    handler: like.main
    events:
      - http:
          path: /notes/{id}/like
          method: post
          cors: true
          authorizer: aws_iam
```
Again, the `like-api` will share the same API endpoint as the `notes-api` service.

Add the handler file `like.js`
``` javascript
import { success } from "../../libs/response-lib";

export async function main(event, context) {
  // business logic code for liking a post

  return success({ status: true });
}
```

Then, go back to Seed and add the new service we just created.

Select **Add a Service**.

![](/assets/best-practices/creating-pull-request-environments-4.png)

Enter the path to the service `services/like-api` and select **Search**.

![](/assets/best-practices/creating-pull-request-environments-5.png)

Since the code has not been committed to git yet, Seed is not able to find the serverless.yml of the service. That is totally fine. We will specify a name for the service `like-api`. Then select **Add Service**.

![](/assets/best-practices/creating-pull-request-environments-6.png)

Now, we have the service added. By default, the new service is added to the latest deploy phase. Let's move it to Phase 2 as it is dependent on the API Gateway resources exported by `notes-api`.

![](/assets/best-practices/creating-pull-request-environments-7.png)

Go back to our command line, and then push the code to the `like` branch.
``` bash
$ git add .
$ git commit -m "Add like API"
$ git push --set-upstream origin like
```

Now go back to Seed, a new stage **like** is created and is being deployed automatically.

![](/assets/best-practices/creating-pull-request-environments-10.png)

After `like` stage successfully deploys, you can get the API endpoint in the stage's resources page. You can use the endpoint in your frontend for testing.

![](/assets/best-practices/creating-pull-request-environments-11.png)

