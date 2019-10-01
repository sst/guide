Beside Lambda and API Gateway, your project will have other AWS services. To run your code locally, you have to simulate the AWS services. Similar to `serverless-offline` simulates API Gateway, there are plugins like `serverless-dynamodb-local` and `serverless-offline-sns` that can simulate DynamoDB and SNS. However, mocking only takes you so far since they do not simulate IAM permission and they are not always updated with the services' latest changes. You want to test your code on real resources asap.

Let's add a new feature that shows recommendation items based on the items in clear the cart (ie. similar to Amazon's customer who bought this also bought this). We will add a new API endpoint `/carts/{cartId}/recommendations`, let's take a look at what our pull request workflow looks like.

# Enable Pull Request workflow on Seed

Go to your app on Seed. Select **Settings**.

![](/assets/best-practices/creating-pull-request-environments-1.png)

Scroll down to **Git Integration**. Then select **Enable Auto-Deploy PRs**.

![](/assets/best-practices/creating-pull-request-environments-2.png)

Select **Enable**.

![](/assets/best-practices/creating-pull-request-environments-3.png)

# Add business logic code

We will create a new feature branch `recommendations`.
``` bash
$ git checkout -b recommendations
```
Create the `recommendations-api` service.
``` bash
$ cd services
$ mkdir recommendations-api
$ cd recommendations-api
```
Add a `serverless.yml`
``` yaml
service: recommendations-api

plugins:
  - serverless-offline

custom:
  stage: ${opt:stage, self:provider.stage}
    
package:
  individually: true

provider:
  name: aws
  region: us-east-1
  runtime: nodejs10.x
  environment:
    stage: ${self:custom.stage}
  apiGateway:
    restApiId:
      'Fn::ImportValue': ApiGatewayRestApiId-${self:custom.stage}
    restApiRootResourceId:
      'Fn::ImportValue': ApiGatewayRestApiRootResourceId-${self:custom.stage}
    restApiResources:
      /carts/{cartId}:
        'Fn::ImportValue': ApiGatewayResourceCartsCartidVarResourceId-${self:custom.stage}

functions:
  getRecommendations:
    handler: getRecommendations.main
    events:
      - http:
          path: /carts/{cartId}/recommendations
          method: get
          cors: true
```
Again, the `recommendations-api` will share the same API endpoint as the `carts-api` service.

Add the handler file `getRecommendations.js`
``` javascript
'use strict';

module.exports.main = (event, context, callback) => {
  const recommendations = [
    // Add fancy machine learning code here
  ];

  callback(null, {
    statusCode: 200,
    body: JSON.stringify(recommendations),
  });                   
};
```
Push the code to the `recommendations` branch.
``` bash
$ git add .
$ git commit -m "Add recommendation API"
$ git push --set-upstream origin recommendations
```
Then, go back to Seed and add the new service we just created.

Select **Add a Service**.

![](/assets/best-practices/creating-pull-request-environments-4.png)

Enter the path to the service `services/recommendations-api` and select **Search**.

![](/assets/best-practices/creating-pull-request-environments-5.png)

Since the service is not in the `master` branch yet, Seed is not able to find the serverless.yml of the service. That is totally fine. We will specify a name for the service `recommendations-api`. Then select **Add Service**.

![](/assets/best-practices/creating-pull-request-environments-6.png)

Now, we have the service added. By default, the new service is added to the latest deploy phase. This is what we want in this case since it imports the API Gateway resources that are exported by `carts-api`.

![](/assets/best-practices/creating-pull-request-environments-7.png)

# Create Pull Request

Go to GitHub, select the `recommendations` branch. Then select **New pull request**.

Select **Create pull request**.

![](/assets/best-practices/creating-pull-request-environments-8.png)

Select **Create pull request**.

![](/assets/best-practices/creating-pull-request-environments-9.png)

Now go back to Seed, a new stage **pr6** is created and is being deployed automatically.

![](/assets/best-practices/creating-pull-request-environments-10.png)

 After `pr6` stage successfully deploys, you can see the deployed API endpoint on the PR page. You can give the endpoint to your frontend team for testing.

![](/assets/best-practices/creating-pull-request-environments-11.png)

You can also access the `pr6` stage on Seed via the **View deployment** button. And you can see the deployment status for each service under **checks**.

![](/assets/best-practices/creating-pull-request-environments-12.png)
