---
layout: example
title: How to use Lambda Layers in your serverless app
short_title: Lambda Layers
date: 2021-05-26 00:00:00
lang: en
index: 2
type: misc
description: In this example we'll look at how to use a Lambda Layer in a serverless app using SST. We'll be using the chrome-aws-lambda Layer to take a screenshot of a webpage and return the image in our API.
short_desc: Using the chrome-aws-lambda layer to take screenshots.
repo: layer-chrome-aws-lambda
ref: how-to-use-lambda-layers-in-your-serverless-app
comments_id: how-to-use-lambda-layers-in-your-serverless-app/2405
---

In this example we will look at how to use [Layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html) in your serverless app with [SST]({{ site.sst_github_repo }}). We'll be using the [chrome-aws-lambda](https://github.com/shelfio/chrome-aws-lambda-layer) Layer to take a screenshot of a webpage and return the image in our API.

We'll be using SST's [Live Lambda Development]({{ site.docs_url }}/live-lambda-development). It allows you to make changes and test locally without having to redeploy.

## Requirements

- Node.js >= 10.15.1
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=starters/typescript-starter layer-chrome-aws-lambda
$ cd layer-chrome-aws-lambda
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

```json
{
  "name": "layer-chrome-aws-lambda",
  "region": "us-east-1",
  "main": "stacks/index.ts"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `services/` — App Code

   The code that's run when your API is invoked is placed in the `services/` directory of your project.

## Creating the API

Let's start by creating our API.

{%change%} Replace the `stacks/MyStack.ts` with the following.

```ts
import { LayerVersion } from "aws-cdk-lib/aws-lambda";
import { Api, StackContext } from "@serverless-stack/resources";

const layerArn =
  "arn:aws:lambda:us-east-1:764866452798:layer:chrome-aws-lambda:22";

export function MyStack({ stack }: StackContext) {
  const layer = LayerVersion.fromLayerVersionArn(stack, "Layer", layerArn);

  // Create a HTTP API
  const api = new Api(stack, "Api", {
    routes: {
      "GET /": {
        function: {
          handler: "functions/lambda.handler",
          // The chrome-aws-lambda layer currently does not work in Node.js 16
          runtime: "nodejs14.x",
          // Increase the timeout for generating screenshots
          timeout: 15,
          // Load Chrome in a Layer
          layers: [layer],
          // Exclude bundling it in the Lambda function
          bundle: { externalModules: ["chrome-aws-lambda"] },
        },
      },
    },
  });

  // Show the endpoint in the output
  stack.addOutputs({
    ApiEndpoint: api.url,
  });
}
```

Here, we are first getting a reference to the [ARN]({% link _chapters/what-is-an-arn.md %}) of the Layer we want to use. Head over to the [chrome-aws-lambda](https://github.com/shelfio/chrome-aws-lambda-layer) Layer repo and grab the one for your region.

We then use the [`Api`]({{ site.docs_url }}/constructs/Api) construct and add a single route (`GET /`). For the function that'll be handling the route, we increase the timeout, since generating a screenshot can take a little bit of time. We then reference the Layer we want and exclude the Lambda function from bundling the [chrome-aws-lambda](https://github.com/alixaxel/chrome-aws-lambda) npm package.

Finally, we output the endpoint of our newly created API.

## Adding function code

Now in our function, we'll be handling taking a screenshot of a given webpage.

{%change%} Replace `services/functions/lambda.ts` with the following.

```ts
import chrome from "chrome-aws-lambda";

// chrome-aws-lambda handles loading locally vs from the Layer
const puppeteer = chrome.puppeteer;

import { APIGatewayProxyHandlerV2 } from "aws-lambda";

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  // Get the url and dimensions from the query string
  const { url, width, height } = event.queryStringParameters!;

  const browser = await puppeteer.launch({
    args: chrome.args,
    executablePath: await chrome.executablePath,
  });

  const page = await browser.newPage();

  await page.setViewport({
    width: Number(width),
    height: Number(height),
  });

  // Navigate to the url
  await page.goto(url!);

  // Take the screenshot
  await page.screenshot();

  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: "Screenshot taken",
  };
};
```

First, we grab the webpage URL and dimensions for the screenshot from the query string. We then launch the browser and navigate to that URL, with those dimensions and take the screenshot.

Now let's install the npm packages we need.

{%change%} Run the below command in the `services/` folder.

```bash
$ npm install puppeteer puppeteer-core chrome-aws-lambda
```

The `puppeteer` packages are used internally by the `chrome-aws-lambda` package.

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm start
```

The first time you run this command it'll take a couple of minutes to deploy your app and a debug stack to power the Live Lambda Development environment.

```
===============
 Deploying app
===============

Preparing your SST app
Transpiling source
Linting source
Deploying stacks
dev-layer-chrome-aws-lambda-my-stack: deploying...

 ✅  dev-layer-chrome-aws-lambda-my-stack


Stack dev-layer-chrome-aws-lambda-my-stack
  Status: deployed
  Outputs:
    ApiEndpoint: https://d9rxpfhft0.execute-api.us-east-1.amazonaws.com
```

Now if you head over to your API endpoint and add the URL and dimensions to the query string:

```
?url=https://sst.dev/examples&width=390&height=640
```

You should see `Screenshot taken` being printed out.

## Returning an image

Now let's make a change to our function so that we return the screenshot directly as an image.

{%change%} Replace the following lines in `services/functions/lambda.ts`.

```ts
// Take the screenshot
await page.screenshot();

return {
  statusCode: 200,
  headers: { "Content-Type": "text/plain" },
  body: "Screenshot taken",
};
```

with:

```ts
// Take the screenshot
const screenshot = await page.screenshot({ encoding: "base64" }) as string;

return {
  statusCode: 200,
  // Return as binary data
  isBase64Encoded: true,
  headers: { "Content-Type": "image/png" },
  body: screenshot,
};
```

Here we are returning the screenshot image as binary data in the body. We are also setting the `isBase64Encoded` option to `true`.

Now if you go back and load the same link in your browser, you should see the screenshot!

![Chrome screenshot in Lambda function](/assets/examples/layer-chrome-aws-lambda/chrome-screenshot-in-lambda-function.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

## Conclusion

And that's it! We've got a completely serverless screenshot taking API that automatically returns an image of any webpage we want. And we can test our changes locally before deploying to AWS! Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
