---
layout: page
title: Serverless Framework vs SST
description: In this post we compare Serverless Framework with Serverless Stack Framework (SST). We look at how to test your serverless apps locally in both the frameworks and how Live Lambda Development works in SST.
---

In this post we compare [Serverless Framework](https://github.com/serverless/serverless) with [Serverless Stack Framework (SST)]({{ site.sst_github_repo }}). We'll also take a deeper look at what makes SST different.

Let's start with some quick background.

## Serverless Framework

Serverless Framework was launched back in 2015. It's far and away the most popular way to build serverless applications. It uses a `serverless.yml` config file to define your infrastructure.

``` yaml
service: my-serverless-app

provider:
  name: aws
  runtime: nodejs12.x
  stage: dev
  region: us-east-1

functions:
  hello:
    handler: handler.hello
    events:
      - http:
          path: hello
          method: get
```

It converts this YAML file to a [CloudFormation template](https://aws.amazon.com/cloudformation/resources/templates/) and deploys it to AWS. However for any other infrastructure, you'll need to define it directly in CloudFormation.

CloudFormation is incredibly verbose and for even simple applications, a template can run over a few thousand lines. For example, here's an excerpt from a Cognito Identity Pool definition in CloudFormation.

``` yml
Resources:
  CognitoIdentityPool:
    Type: AWS::Cognito::IdentityPool
    Properties:
      IdentityPoolName: MyIdentityPool
      AllowUnauthenticatedIdentities: false
      CognitoIdentityProviders:
        - ClientId:
            Ref: CognitoUserPoolClient
          ProviderName:
            Fn::GetAtt: [ "CognitoUserPool", "ProviderName" ]

# ...
```

To fix this, [Serverless Inc.](https://www.serverless.com) (the company behind Serverless Framework) created, [Serverless Components](https://github.com/serverless/components). These allow you to deploy use-case specific serverless applications; including Express apps, React apps, GraphQL apps etc. The critical difference between Serverless Framework and Serverless Components is that in the case of a Component, your source code and AWS credentials will pass through Serverless Inc.'s own servers.

Here's the relevant disclaimer from the [Serverless Components README](https://github.com/serverless/components#readme).

> ...your **source code** and **temporary credentials** will pass through an innovative, hosted deployment engine (similar to a CI/CD product).

In addition to the above, Serverless Inc. provides [a monitoring service](https://www.serverless.com/monitoring) and will prompt you to create an account with them when you deploy your applications.

Next, let's look at the local development workflow for Serverless Framework.

### Developing Locally in Serverless Framework

Locally, it mocks the Lambda functions by running them in a Node.js process (if the runtime is set to Node.js). This means that when you are testing them locally, you'll need to isolate the Lambda functions and test them. As a result Serverless Framework developers have two major ways of developing locally; mocking the AWS services or deploying repeatedly.

> Serverless Framework developers test locally by either mocking the AWS services or repeatedly deploying to AWS.

#### Mocking Locally and Using serverless-offline

It's common to have a list of mock events that you can use to test your Lambda functions. For example, to test an API that needs authentication and takes a request body, you might have a file that looks like:

``` json
{
  "body": "{\"content\":\"hello world\",\"attachment\":\"hello.jpg\"}",
  "requestContext": {
    "identity": {
      "cognitoIdentityId": "USER-SUB-1234"
    }
  }
}
```

To test your Lambda function you'll run the following while pointing to the mock event above.

``` bash
$ serverless invoke local --function create --path mocks/create-event.json
```

Alternatively, you can use the community created [serverless-offline](https://github.com/dherault/serverless-offline) plugin. It can mock API endpoints. So if your application has an API endpoint, this will run a local server to mock that endpoint and invoke your Lambda function. However, if your API uses some form of authentication, you'll need to mock that as well.

> You need community plugins like serverless-offline to mock the AWS API Gateway locally. But these only work for some of the AWS services.

The above works mainly for API endpoints. For other services you'll need to find a different plugin or use something like [LocalStack](https://github.com/localstack/localstack). But these are slow, incomplete, and hard to use.

#### Repeatedly Deploying to AWS

As a result, most developers eventually end up deploying to AWS to test their changes. So their workflow looks like.

1. Make a code change to a Lambda function.
2. Run `serverless deploy function -f functionName`
3. Invoke the service that triggers the function 
4. Wait for the CloudWatch logs by running `serverless logs -f functionName`
5. Repeat the process...

While this process works, it requires you to wait to see your results. Making for a really slow feedback loop.

> Testing locally by repeatedly deploying your Lambda function creates a slow feedback loop.

## Serverless Stack Framework (SST)

In contrast, [SST]({{ site.sst_github_repo }}) was launched in early 2021 and has since grown rapidly to become the new way to build full-stack serverless applications. It uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}) to define your infrastructure. You define your stacks using real programming languages like JavaScript or TypeScript.

``` js
export default class MyStack extends Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });
  }
}
```

The CDK code here gets compiled down to CloudFormation templates, similar to the Serverless Framework case. But CDK code allows you to easily create and maintain your infrastructure, instead of having to work with verbose YAML files. Also, since we are working with a programming language, we can create reusable classes to help us maintain our codebase. 

### Developing Locally in SST

SST was initially developed to solved the local development problem with serverless. It features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment. It allows you test your serverless apps live.

It does this by deploying your application to AWS and proxying any Lambda function requests to your local machine. It'll then execute these locally and send the response back to AWS. This means that you don't need to mock anything and you can test against your deployed infrastructure.

> SST allows you to test against your deployed infrastructure by proxying any requests from AWS to your local machine.

It also allows you to set breakpoints and test against live data from the connected AWS services. SST will hot-reload your changes and blocks any incoming requests to ensure that you are always testing against the latest changes.

> You can set breakpoints and test against live data in SST.

We'll look at how to do this a little later in this post.

## Comparison

Let's quickly summarize the comparison between the two frameworks.

| | Serverless Framework | SST | 
|-|----------------------|-----|
| Founded | 2015 | 2021 |
| Architecture | Partly open source with hosted deployment engine | Completely open source and self-hosted |
| Infrastructure Definition | [CloudFormation](https://aws.amazon.com/cloudformation/resources/templates/) | [CDK]({% link _chapters/what-is-aws-cdk.md %}) |
| | Hard to manage large applications | Easy to reuse infrastructure code |
| Local Development | Mocking or [serverless-offline](https://github.com/dherault/serverless-offline) | [Live Lambda Dev]({{ site.docs_url }}/live-lambda-development) |
|                   | Repeatedly deploying changes  | Setting breakpoints |
| Flexibility | Use community plugins  | Use any CDK construct |
|             | Create your own plugin | Write your own CDK construct |

## Live Lambda Development

Next, let's look at in detail how SST allows you to test your serverless apps locally. We'll be using VS Code in this example. SST allows you to set breakpoints through VS Code.

{%change%} Let's start by using the VS Code example.

``` bash
$ npx create-serverless-stack@latest --example vscode
$ cd vscode
```

This example comes with a VS Code [Launch Configuration](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations), [`.vscode/launch.json`]({{ site.sst_github_repo }}{{ site.sst_github_examples_prefix }}vscode/.vscode/launch.json).

We are creating a simple API in our app. It's defined in `stacks/MyStack.ts`.

``` ts
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope: sst.App, id: string, props?: sst.StackProps) {
    super(scope, id, props);

    // Create the HTTP API
    const api = new sst.Api(this, "Api", {
      routes: {
        "GET /": "src/lambda.handler",
      },
    });

    // Show the API endpoint in the output
    this.addOutputs({
      ApiEndpoint: api.url,
    });
  }
}
```

And when we hit this endpoint, it triggers our _Hello World_ Lambda function in `src/lambda.ts`.

``` ts
import { APIGatewayProxyEventV2, APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (
  event: APIGatewayProxyEventV2
) => {
  const message = `The time in Lambda is ${event.requestContext.time}.`;
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, World! ${message}`,
  };
};
```

Now if you open up your project in VS Code, you can set a breakpoint in your `src/lambda.ts`.

Next, head over to VS Code. In the **Run And Debug** tab > select our Launch Configuration, **Debug SST Start**, and hit **Play**.

![Set Lambda function breakpoint in VS Code](/assets/resources/vscode/set-lambda-function-breakpoint-in-vs-code.png)

The first time you start the Live Lambda Development environment, it'll take a couple of minutes to do the following:

1. It'll ask you for a default stage to deploy to, based on your AWS username. This ensures that you and your teammates have separate local environments.
2. It'll then bootstrap your AWS environment to use CDK.
3. Deploy a debug stack to power the Live Lambda Development environment.
4. Deploy your app, but replace the functions in the `src/` directory with ones that connect to your local client.
5. Start up a local client.

Once complete, you should see something like this.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-vscode-my-stack: deploying...

 ✅  dev-vscode-my-stack


Stack dev-vscode-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://siyp617yh1.execute-api.us-east-1.amazonaws.com
```

The `ApiEndpoint` is the API we just created. Now if you head over to that endpoint in your browser, you'll notice that you'll hit the breakpoint.

![Hitting a breakpoint in a Lambda function in VS Code](/assets/resources/vscode/set-lambda-hitting-a-breakpoint-in-a-lambda-function-in-vs-code.png)

Here on the left you'll be able to inspect all the Lambda function variables that are coming from AWS. And since you are testing against a deployed endpoint, this setup will work even if there was authentication involved.

Here is a video of it in action.

<div class="video-wrapper">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/2w4A06IsBlU" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

And that's it! You can now add other parts of your infrastructure with [SST's constructs]({{ site.docs_url }}), CDK's constructs, or by adding your own.

As a next step, you can check out this free 1000 page ebook on how to build full-stack serverless applications using SST and React. It's the most widely read resource for serverless and a great way to get started.

<div class="extras">
  <div class="container">
    <div class="newsletter">
      {% include newsletter-form.html type="examples" %}
    </div>
  </div>
</div>

Finally, you can remove the resources created in this example using the following command.

``` bash
$ npx sst remove
```

You can also [check out the source for this example]({{ site.sst_github_repo }}{{ site.sst_github_examples_prefix }}vscode) and read about [Live Lambda Development]({{ site.docs_url }}/live-lambda-development).
