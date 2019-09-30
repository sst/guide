---
layout: post
title: Sharing API endpoint between API services
description: 
date: 2019-09-29 00:00:00
comments_id: 
---

In our example, we have two services with API endpoints, `carts-api` and `checkout-api`. In this chapter, we are going to look at how to configure API Gateway such that both services are served out via a single API endpoint.

The API path we want to setup is:

- `carts-api` list all carts ⇒ GET `https://api.example.com/carts`
- `carts-api` get one cart ⇒ GET `https://api.example.com/carts/{cartId}`
- `carts-api` update cart ⇒ POST `https://api.example.com/carts/{cartId}`
- `checkout-api` checkout ⇒ POST `https://api.example.com/carts/{cartId}/checkout`

### How paths work in API Gateway

API Gateway is structured in a slightly tricky way. Let's look at this in detail.

- Each path part is a separate API Gateway resource object.
- And a path part is a child resource of the preceding part.

Let's look at an example. So `/carts` is a child of `/`. And `/carts/{cartId}` is a child of `/carts`.

Based on our setup, we want the `checkout-api` to have the `/carts/{cartId}/checkout` path. And this would be a child resource of `/carts/{cartId}`. However, `/carts/{cartId}` is created in the `carts-api` service. So we'll need to find a way to share the resource across services.

### Sharing API Gateway projects

To do this, the `carts-api` needs to share the API Gateway settings and the parent part `/carts/{cartId}`.

We'll add the following outputs to the `carts-api`'s `serverless.yml`:

TODO: FORMAT THESE SNIPPETS

``` yml
service: carts-api

custom:
  stage: ${opt:stage, self:provider.stage}

...

resource:
  - Outputs:
      ApiGatewayRestApiId:
        Value:
          Ref: ApiGatewayRestApi
        Export:
          Name: ApiGatewayRestApiId-${self:custom.stage}

      ApiGatewayRestApiRootResourceId:
        Value:
           Fn::GetAtt:
            - ApiGatewayRestApi
            - RootResourceId
        Export:
          Name: ApiGatewayRestApiRootResourceId-${self:custom.stage}

      ApiGatewayResourceCartsCartidVarResourceId:
        Value:
          Ref: ApiGatewayResourceCartsCartidVar
        Export:
          Name: ApiGatewayResourceCartsCartidVarResourceId-${self:custom.stage}
```

Then open `checkout-api`'s serverless.yml and tell Serverless Framework to import and reuse the API Gateway settings from the `carts-api` service.

``` yml
service: checkout-api

custom:
  stage: ${opt:stage, self:provider.stage}

provider:
  apiGateway:
    restApiId:
      'Fn::ImportValue': ApiGatewayRestApiId-${self:custom.stage}
    restApiRootResourceId:
      'Fn::ImportValue': ApiGatewayRestApiRootResourceId-${self:custom.stage}
    restApiResources:
      /carts/{cartId}:
        'Fn::ImportValue': ApiGatewayResourceCartsCartidVarResourceId-${self:custom.stage}
...

functions:
  checkout:
    handler: checkout.main
    events:
      - http:
          path: /carts/{cartId}/checkout
          method: post
```

Now when you deploy the `checkout-api` service, instead of creating a new API Gateway project, Serverless Framework is going to reuse the project you imported.

#### Dependency

By sharing API Gateway project, we are making the `checkout-api` depend on the `carts-api`. When deploying, you need to ensure the `carts-api` is deployed first.

#### Limitations

Note that, a path part can only be created **ONCE**. Let's look at an example to understand how this works. Say you need to add another API service that uses the following endpoint.

```
https://api.example.com/carts/{cartId}/checkout/xyz
```

This new service **CANNOT** import `/carts/{cartId}` from the `carts-api`.

This is because, Serverless Framework tries to create the following two path parts:

1. `/carts/{cartId}/checkout`
2. `/carts/{cartId}/checkout/xyz`

But `/carts/{cartId}/checkout` has already been created in the `checkout-api` service. So if you were to deploy this new service, CloudFormation will fail and complain that the resource already exists.

You **HAVE TO** import `/carts/{cartId}/checkout` from the `checkout-api`, so the new service will only need to create the `/carts/{cartId}/checkout/xyz` part.

Now we are done organizing our services and we are ready to deploy them. To recap, our jobs services share a resource — an SNS topic. And our API services share a resource as well — the API Gatway endpoint. Next we'll look at how to deploy services with dependencies.
