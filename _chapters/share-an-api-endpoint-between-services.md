---
layout: post
title: Share an API Endpoint Between Services
description: To share the same API Gateway domain across multiple services in Serverless we need to "Export" the API Gateway Rest API Id and the API Gateway "RootResourceId" as a CloudFormation cross-stack reference. This will allow us to share the same API Gateway URL across Serverless projects.
redirect_from: /chapters/api-gateway-domains-across-services.html
date: 2019-09-29 00:00:00
comments_id: api-gateway-domains-across-services/408
---

In this chapter we will look at how to work with API Gateway across multiple services. A challenge that you run into when splitting your APIs into multiple services is sharing the same domain for them. You might recall that APIs that are created as a part of the Serverless service get their own unique URL that looks something like:

```
https://z6pv80ao4l.execute-api.us-east-1.amazonaws.com/dev
```

When you attach a custom domain for your API, it is attached to a specific endpoint like the one above. This means that if you create multiple API services, they will all have unique endpoints.

You can assign different base paths for your custom domains. For example, `api.example.com/notes` can point to one service while `api.example.com/billing` can point to another. But if you try to split your `notes` service up, you'll face the challenge of sharing the custom domain across them.

In our notes app, we have two services with API endpoints, `notes-api` and `billing-api`. In this chapter, we are going to look at how to configure API Gateway such that both services are served out via a single API endpoint.

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

### Notes Service

To do this, the `notes-api` needs to share the API Gateway project and the root path `/`.

In our [serverless-stack-demo-ext-api]({{ site.backend_ext_api_github_repo }}) repo, go into the `services/notes-api/` directory. In the `serverless.yml`, near the end, you will notice:

``` yml
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
```

Let's look at what we are doing here.

1. The first cross-stack reference that needs to be shared is the API Gateway Id that is created as a part of this service. We are going to export it with the name `${self:custom.stage}-ExtApiGatewayRestApiId`. Again, we want the exports to work across all our environments/stages and so we include the stage name as a part of it. The value of this export is available as a reference in our current stack called `ApiGatewayRestApi`.
2. We also need to export the `RootResourceId`. This is a reference to the `/` path of this API Gateway project. To retrieve this Id we use the `Fn::GetAtt` CloudFormation function and pass in the current `ApiGatewayRestApi` and look up the attribute `RootResourceId`. We export this using the name `${self:custom.stage}-ExtApiGatewayRestApiRootResourceId`.

### Billing Service

Let's look at how we are importing the above. Open the `billing-api` service in the `services/` directory.

``` yml
...

provider:
  apiGateway:
    restApiId:
      'Fn::ImportValue': ${self:custom.stage}-ExtApiGatewayRestApiId
    restApiRootResourceId:
      'Fn::ImportValue': ${self:custom.stage}-ExtApiGatewayRestApiRootResourceId
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

To share the same API Gateway domain as our `notes-api` service, we are adding an `apiGateway:` section to the `provider:` block.

  1. Here we state that we want to use the `restApiId` of our notes service. We do this by using the cross-stack reference `'Fn::ImportValue': ${self:custom.stage}-ExtApiGatewayRestApiId` that we had exported above.

  2. We also state that we want all the APIs in our service to be linked under the root path of our notes service. We do this by setting the `restApiRootResourceId` to the cross-stack reference `'Fn::ImportValue': ${self:custom.stage}-ExtApiGatewayRestApiRootResourceId` from above.

Now when you deploy the `billing-api` service, instead of creating a new API Gateway project, Serverless Framework is going to reuse the project you imported.

The key thing to note in this setup is that API Gateway needs to know where to attach the routes that are created in this service. We want the `/billing` path to be attached to the root of our API Gateway project. Hence the `restApiRootResourceId` points to the root resource of our `notes-api` service. Of course we don't have to do it this way. We can organize our service such that the `/billing` path is created in our main API service and we link to it here.

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

Now we are done organizing our services and we are ready to deploy them. To recap, we have a couple of dependencies in our resources repo and a couple in our API repo.
