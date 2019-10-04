---
layout: post
title: Sharing API endpoint between API services
description: 
date: 2019-09-29 00:00:00
comments_id: 
---

In our example, we have two services with API endpoints, `notes-api` and `billing-api`. In this chapter, we are going to look at how to configure API Gateway such that both services are served out via a single API endpoint.

The API path we want to setup is:

- `notes-api` list all notes ⇒ GET `https://api.example.com/notes`
- `notes-api` get one note ⇒ GET `https://api.example.com/notes/{noteId}`
- `notes-api` create one note ⇒ POST `https://api.example.com/notes`
- `notes-api` update one note ⇒ PUT `https://api.example.com/notes/{noteId}`
- `notes-api` delete one note ⇒ DELETE `https://api.example.com/notes/{noteId}`
- `billing-api` checkout ⇒ POST `https://api.example.com/billing`

### How paths work in API Gateway

API Gateway is structured in a slightly tricky way. Let's look at this in detail.

- Each path part is a separate API Gateway resource object.
- And a path part is a child resource of the preceding part.

So the part path `/notes`, is a child resource of `/`. And `/notes/{noteId}` is a child resource of `/notes`.

Based on our setup, we want the `billing-api` to have the `/billing` path. And this would be a child resource of `/`. However, `/` is created in the `notes-api` service. So we'll need to find a way to share the resource across services.

### Sharing API Gateway projects

To do this, the `notes-api` needs to share the API Gateway project and the root path `/`.

We'll add the following outputs to the `notes-api`'s `serverless.yml`:

TODO: FORMAT THESE SNIPPETS

``` yml
service: notes-api

custom:
  stage: ${opt:stage, self:provider.stage}

...

resource:
  Outputs:
    ApiGatewayRestApiId:
      Value:
        Ref: ApiGatewayRestApi
      Export:
        Name: ${self:custom.stage}-ApiGatewayRestApiId
  
    ApiGatewayRestApiRootResourceId:
      Value:
         Fn::GetAtt:
          - ApiGatewayRestApi
          - RootResourceId 
      Export:
        Name: ${self:custom.stage}-ApiGatewayRestApiRootResourceId
```

Then open `billing-api`'s serverless.yml and tell Serverless Framework to import and reuse the API Gateway settings from the `notes-api` service.

``` yml
service: billing-api

custom:
  stage: ${opt:stage, self:provider.stage}

provider:
  apiGateway:
    restApiId:
      'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiId
    restApiRootResourceId:
      'Fn::ImportValue': ${self:custom.stage}-ApiGatewayRestApiRootResourceId
...

functions:
  billing:
    handler: billing.main
    events:
      - http:
          path: billing
          method: post
          cors: true
          authorizer: aws_iam
```

Now when you deploy the `billing-api` service, instead of creating a new API Gateway project, Serverless Framework is going to reuse the project you imported.

#### Dependency

By sharing API Gateway project, we are making the `billing-api` depend on the `notes-api`. When deploying, you need to ensure the `notes-api` is deployed first.

#### Limitations

Note that, a path part can only be created **ONCE**. Let's look at an example to understand how this works. Say you need to add another API service that uses the following endpoint.

```
https://api.example.com/billing/xyz
```

This new service **CANNOT** import `/` from the `notes-api`.

This is because, Serverless Framework tries to create the following two path parts:

1. `/billing`
2. `/billing/xyz`

But `/billing` has already been created in the `billing-api` service. So if you were to deploy this new service, CloudFormation will fail and complain that the resource already exists.

You **HAVE TO** import `/billing` from the `billing-api`, so the new service will only need to create the `/billing/xyz` part.

Now we are done organizing our services and we are ready to deploy them. To recap, our jobs services share a resource — an SNS topic. And our API services share a resource as well — the API Gatway endpoint. Next we'll look at how to deploy services with dependencies.
