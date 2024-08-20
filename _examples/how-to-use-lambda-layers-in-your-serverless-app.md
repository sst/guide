---
layout: example
title: How to use Lambda Layers in your serverless app
short_title: Lambda Layers
date: 2021-05-26 00:00:00
lang: en
index: 2
type: misc
description: In this example we'll look at how to use a Lambda Layer in a serverless app using SST. We'll be using the @sparticuz/chromium Layer to take a screenshot of a webpage and return the image in our API.
short_desc: Using the @sparticuz/chromium layer to take screenshots.
repo: layer-chrome-aws-lambda
ref: how-to-use-lambda-layers-in-your-serverless-app
comments_id: how-to-use-lambda-layers-in-your-serverless-app/2405
---

In this example we will look at how to use [Layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html) in your serverless app with [SST]({{ site.sst_github_repo }}). We'll be using the [@sparticuz/chromium](https://github.com/Sparticuz/chromium) Layer to take a screenshot of a webpage and return the image in our API.

We'll be using SST's [Live Lambda Development]({{ site.v2_url }}/live-lambda-development). It allows you to make changes and test locally without having to redeploy.

## Requirements

- Node.js 16 or later
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=base/example layer-chrome-aws-lambda
$ cd layer-chrome-aws-lambda
$ npm install
```

By default, our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.config.ts` in your project root.

```js
import { SSTConfig } from "sst";
import { Api } from "sst/constructs";

export default {
  config(_input) {
    return {
      name: "layer-chrome-aws-lambda",
      region: "us-east-1",
    };
  },
} satisfies SSTConfig;
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _archives/what-is-aws-cdk.md %}), to create the infrastructure.

2. `packages/functions/` — App Code

   The code that's run when your API is invoked is placed in the `packages/functions/` directory of your project.

3. `layers/` — Lambda Layers

   The Lambda layer that contains Chromium.

## Creating the API

Let's start by creating our API.

{%change%} Replace the `stacks/ExampleStack.ts` with the following.

```ts
import * as lambda from "aws-cdk-lib/aws-lambda";
import { Api, StackContext } from "sst/constructs";

export function ExampleStack({ stack }: StackContext) {
  const layerChromium = new lambda.LayerVersion(stack, "chromiumLayers", {
    code: lambda.Code.fromAsset("layers/chromium"),
  });

  // Create a HTTP API
  const api = new Api(stack, "Api", {
    routes: {
      "GET /": {
        function: {
          handler: "packages/functions/src/lambda.handler",
          // Use 18.x here because in 14, 16 layers have some issue with using NODE_PATH
          runtime: "nodejs18.x",
          // Increase the timeout for generating screenshots
          timeout: 15,
          // Increase the memory
          memorySize: "2 GB",
          // Load Chrome in a Layer
          layers: [layerChromium],
          // Exclude bundling it in the Lambda function
          nodejs: {
            esbuild: {
              external: ["@sparticuz/chromium"],
            },
          },
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

We then use the [`Api`]({{ site.v2_url }}/constructs/Api) construct and add a single route (`GET /`). For the function that'll be handling the route, we increase the timeout, since generating a screenshot can take a little bit of time.

We create a layer based on what's in the `layers/chromium` directory, we'll download this below. We also exclude the Lambda function from bundling the [@sparticuz/chromium](https://github.com/Sparticuz/chromium) npm package.

Finally, we output the endpoint of our newly created API.

## Install Chromium

We need to install Chromium so we can run it locally and we need to install it so we can package it up as a Lambda layer.

### Installing locally

{%change%} Download Chromium locally, then you will have `YOUR_LOCAL_CHROMIUM_PATH`. You will need it in Lambda function to run Chromium locally.
  
```bash
$ npx @puppeteer/browsers install chromium@latest --path /tmp/localChromium
```

### Download Layer

{%change%} Create a `layers/chromium` directory.

```bash
$ mkdir -p layers/chromium
```

{%change%} Download the asset that looks like `chromium-v121.0.0-layer.zip` from the [@sparticuz/chromium](https://github.com/Sparticuz/chromium/releases/) GitHub releases.

{%change%} Unzip and copy the `node_modules/` directory to the `layers/chromium/` directory.

## Adding function code

Now in our function, we'll be handling taking a screenshot of a given webpage.

{%change%} Replace `packages/functions/src/lambda.ts` with the following.

```ts
import puppeteer from "puppeteer-core";
import chromium from "@sparticuz/chromium";

// chrome-aws-lambda handles loading locally vs from the Layer

import { APIGatewayProxyHandlerV2 } from "aws-lambda";

// This is the path to the local Chromium binary
const YOUR_LOCAL_CHROMIUM_PATH = "/tmp/localChromium/chromium/mac-1165945/chrome-mac/Chromium.app/Contents/MacOS/Chromium";

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  // Get the url and dimensions from the query string
  const { url, width, height } = event.queryStringParameters!;

  if (!url) {
    return {
      statusCode: 400,
      body: "Please provide a url",
    };
  }

  const browser = await puppeteer.launch({
    args: chromium.args,
    defaultViewport: chromium.defaultViewport,
    executablePath: process.env.IS_LOCAL
      ? YOUR_LOCAL_CHROMIUM_PATH
      : await chromium.executablePath(),
    headless: chromium.headless,
  });

  const page = await browser.newPage();

  if (width && height) {
    await page.setViewport({
      width: Number(width),
      height: Number(height),
    });
  }

  // Navigate to the url
  await page.goto(url!);

  // Take the screenshot
  const screenshot = (await page.screenshot({ encoding: "base64" })) as string;

  const pages = await browser.pages();
  for (let i = 0; i < pages.length; i++) {
    await pages[i].close();
  }

  await browser.close();

  return {
    headers: { "Content-Type": "text/plain" },
    body: "Screenshot taken",
  };
};

```

First, we grab the webpage URL and dimensions for the screenshot from the query string. We then launch the browser and navigate to that URL, with those dimensions and take the screenshot.

Now let's install the npm packages we need. You need to check [Puppeteer's Chromium Support page](https://pptr.dev/chromium-support) and install the **correct version of Chromium**. At the moment writing this tutorial, `puppeteer-core@20` is compatible with `Chromium@113` is most stable.

{%change%} Run the below command in the `packages/functions/` folder.

```bash
$ npm install puppeteer-core@20.1.2 @sparticuz/chromium@113.0.1
```

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.v2_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

```bash
$ npm run dev
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
dev-layer-chrome-aws-lambda-ExampleStack: deploying...

 ✅  dev-layer-chrome-aws-lambda-ExampleStack


Stack dev-layer-chrome-aws-lambda-ExampleStack
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

{%change%} Replace the following lines in `packages/functions/src/lambda.ts`.

```typescript
// Take the screenshot
await page.screenshot();

return {
  statusCode: 200,
  headers: { "Content-Type": "text/plain" },
  body: "Screenshot taken",
};
```

with:

```typescript
// Take the screenshot
const screenshot = (await page.screenshot({ encoding: "base64" })) as string;

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
