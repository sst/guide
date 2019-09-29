# Sharing API endpoint between API services

In our example, we have two services with API endpoints, `carts-api` and `checkout-api`. In this chapter, we are going to look at how to configure API Gateway such that both services are served out via a single API endpoint.

The API path we want to setup is:

- `carts-api` list all carts ⇒ GET [https://base...domain/carts](https://base...domain/carts)
- `carts-api` get one cart ⇒ GET [https://base...domain/carts](https://base...domain/carts)/{cartId}
- `carts-api` update cart ⇒ POST [https://base...domain/carts](https://base...domain/carts)/{cartId}
- `checkout-api` checkout ⇒ POST [https://base...domain/carts](https://base...domain/carts)/{cartId}/checkout

API Gateway is structured such that each path part is an API Gateway resource object. And is a child resource of the previous part. For example:

- `/carts` is a child of `/`; and
- `/carts/{cartId}` is a child of `/carts`

And we are going to make

- `/carts/{cartId}/checkout` is a child of `/carts/{cartId}`

# Sharing API Gateway Project

To do that, `carts-api` needs to share the API Gateway settings and the parent part `/carts/{cartId}`.

Open `carts-api`'s serverless.yml and add the following outputs:
```
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
    
          ApiGatewayResourceCartsVarResourceId:
            Value:
    					Ref: ApiGatewayResourceCartsVar
            Export:
              Name: ApiGatewayResourceCartsVarResourceId-${self:custom.stage}
```
Then open `checkout-api`'s serverless.yml and tell Serverless Framework to import and reuse the API Gateway settings.
```
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
            'Fn::ImportValue': ApiGatewayResourceCartsVarResourceId-${self:custom.stage}
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

# Dependency

By sharing API Gateway project, we are making the `checkout-api` depend on the `carts-api`. When deploying, you need to ensure the `carts-api` is deployed first.

# What you cannot do?

A path part can only be created once. For example, if you need to add another api service. And the Lambda gets triggered by

[https://base...domain/carts](https://base...domain/carts)/{cartId}/checkout/xyz

This new service **CANNOT** import `/carts/{cartId}` from `carts-api`. Serverless Framework is going to create two parts:

- `/carts/{cartId}/checkout`; and
- `/carts/{cartId}/checkout/xyz`

But `/carts/{cartId}/checkout` is already created in the `checkout-api`, and if you were to deploy the new service, CloudFormation will fail and complain resource already exists.

You **HAVE TO** import `/carts/{cartId}/checkout` from the `checkout-api`, so the new service will only need to create `/carts/{cartId}/checkout/xyz`.
