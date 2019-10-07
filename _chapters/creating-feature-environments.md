---
layout: post
title: Creating feature environments
description: In this chapter we look at how to create feature environments for your Serverless app. We'll go over the process of creating a new feature branch in Git and adding a new Serverless service using Seed.
date: 2019-10-02 00:00:00
comments_id: 
---

Over the last couple of chapters we looked at how to work on Lambda and API Gateway locally. However, besides Lambda and API Gateway, your project will have other AWS services. To run your code locally, you have to simulate all the AWS services. Similar to `serverless-offline`, there are plugins like `serverless-dynamodb-local` and `serverless-offline-sns` that can simulate DynamoDB and SNS. However, mocking only takes you so far since they do not simulate IAM permissions and they are not always up to date with the services' latest changes. You want to test your code with the real resources.

Let's add a new feature that lets you like a note. We will add a new API endpoint `/notes/{id}/like`, let's take a look at what our feature branch workflow looks like.

# Enable Branch workflow on Seed

Go to your app on Seed. Select **Settings**.

![](/assets/best-practices/creating-feature-1.png)

Scroll down to **Git Integration**. Then select **Enable Auto-Deploy Branches**.

![](/assets/best-practices/creating-feature-2.png)

Select the **dev** stage, since we want the stage to be deployed into the **Development stage. Select **Enable Auto-Deploy**.

![](/assets/best-practices/creating-feature-3.png)

# Add business logic code

We will create a new feature branch `like`.
``` bash
$ git checkout -b like
```
First, go into the `notes-api` and export the `/notes/{id}` API path.  Open the `serverless.yml` in the `notes-api` service, and append to the resource outputs.
``` yaml
ApiGatewayResourceNotesIdVarId:
  Value:
    Ref: ApiGatewayResourceNotesIdVar
  Export:
    Name: ${self:custom.stage}-ExtApiGatewayResourceNotesIdVarId
```

Resource outputs should look like:
``` yaml
...
  - Outputs:
      ApiGatewayRestApiId:
        Value:
          Ref: ApiGatewayRestApi
        Export:
          Name: ${self:custom.stage}-ExtApiGatewayRestApiId

      ApiGatewayRestApiRootResourceId:
        Value:
           Fn::GetAtt:
            - ApiGatewayRestApi
            - RootResourceId
        Export:
          Name: ${self:custom.stage}-ExtApiGatewayRestApiRootResourceId

      ApiGatewayResourceNotesIdVarId:
        Value:
          Ref: ApiGatewayResourceNotesIdVar
        Export:
          Name: ${self:custom.stage}-ExtApiGatewayResourceNotesIdVarId
```

Create the `like-api` service.
``` bash
$ cd services
$ mkdir like-api
$ cd like-api
```
Add a `serverless.yml`
``` yaml
service: notes-app-ext-like-api

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
      'Fn::ImportValue': ${self:custom.stage}-ExtApiGatewayRestApiId
    restApiRootResourceId:
      'Fn::ImportValue': ${self:custom.stage}-ExtApiGatewayRestApiRootResourceId
    restApiResources:
      /notes/{id}:
        'Fn::ImportValue': ${self:custom.stage}-ExtApiGatewayResourceNotesIdVarId

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

![](/assets/best-practices/creating-feature-4.png)

Enter the path to the service `services/like-api` and select **Search**.

![](/assets/best-practices/creating-feature-5.png)

Since the code has not been committed to git yet, Seed is not able to find the serverless.yml of the service. That is totally fine. We will specify a name for the service `like-api`. Then select **Add Service**.

![](/assets/best-practices/creating-feature-6.png)

Now, we have the service added.

![](/assets/best-practices/creating-feature-7.png)

By default, the new service is added to the latest deploy phase. Let's head into the **Manage Deploy Phases** in the app settings, and move it to Phase 2 as it is dependent on the API Gateway resources exported by `notes-api`.

![](/assets/best-practices/creating-feature-8.png)

Go back to our command line, and then push the code to the `like` branch.
``` bash
$ git add .
$ git commit -m "Add like API"
$ git push --set-upstream origin like
```

Now go back to Seed, a new stage **like** is created and is being deployed automatically.

![](/assets/best-practices/creating-feature-9.png)

After `like` stage successfully deploys, you can get the API endpoint in the stage's resources page. Select the **like** stage.
![](/assets/best-practices/creating-feature-10.png)

Select **View Resources** on **notes-api** service.
![](/assets/best-practices/creating-feature-11.png)

Scroll down and you will see the API Gateway endpoint for the **like** stage.
![](/assets/best-practices/creating-feature-12.png)

You can use the endpoint in your frontend for testing.
