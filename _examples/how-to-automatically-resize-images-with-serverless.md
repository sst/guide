---
layout: example
title: How to automatically resize images with serverless
date: 2021-02-08 00:00:00
lang: en
description: In this example we will look at how to automatically resize images that are uploaded to your S3 bucket using Serverless Stack (SST). We'll be using the sst.Bucket construct and a Lambda layer to set this up.
repo: bucket-image-resize
ref: how-to-automatically-resize-images-with-serverless
comments_id: how-to-automatically-resize-images-with-serverless/2399
---

In this example we will look at how to automatically resize images that are uploaded to your S3 bucket using [Serverless Stack (SST)]({{ site.sst_github_repo }}). We'll be using the [Sharp](https://github.com/lovell/sharp) package as a [Lambda Layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html).

We'll be using SST's [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development). It allows you to make changes and test locally without having to redeploy.

Here is a video of it in action.

<div class="video-wrapper">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/1m9Pl4oZBnw" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

## Requirements

- Node.js >= 10.15.1
- We'll be using Node.js (or ES) in this example but you can also use TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

``` bash
$ npx create-serverless-stack@latest bucket-image-resize
$ cd bucket-image-resize
```

By default our app will be deployed to an environment (or stage) called `dev` and the `us-east-1` AWS region. This can be changed in the `sst.json` in your project root.

``` json
{
  "name": "bucket-image-resize",
  "stage": "dev",
  "region": "us-east-1"
}
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `src/` — App Code

   The code that's run when your API is invoked is placed in the `src/` directory of your project.

## Creating the bucket

Let's start by creating a bucket.

{%change%} Replace the `stacks/MyStack.js` with the following.

``` js
import { EventType } from "@aws-cdk/aws-s3";
import * as lambda from "@aws-cdk/aws-lambda";
import * as sst from "@serverless-stack/resources";

export default class MyStack extends sst.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    // Create a new bucket
    const bucket = new sst.Bucket(this, "Bucket", {
      notifications: [
        {
          function: {
            handler: "src/resize.main",
            bundle: {
              externalModules: ["sharp"],
            },
            layers: [
              new lambda.LayerVersion(this, "SharpLayer", {
                code: lambda.Code.fromAsset("layers/sharp"),
              }),
            ],
          },
          notificationProps: {
            events: [EventType.OBJECT_CREATED],
          },
        },
      ],
    });

    // Allow the notification functions to access the bucket
    bucket.attachPermissions([bucket]);

    // Show the endpoint in the output
    this.addOutputs({
      BucketName: bucket.s3Bucket.bucketName,
    });
  }
}
```

This creates a S3 bucket using the [`sst.Bucket`](https://docs.serverless-stack.com/constructs/Bucket) construct.

We are subscribing to the `OBJECT_CREATED` notification with a [`sst.Function`](https://docs.serverless-stack.com/constructs/Function). The image resizing library that we are using, [Sharp](https://github.com/lovell/sharp), needs to be compiled specifically for the target runtime. So we are going to use a [Lambda Layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html) to upload it. Locally, the `sharp` package is not compatible with how our functions are bundled. So we are marking it in the `externalModules`.

Finally, we are allowing our functions to access the bucket by calling `attachPermissions`. We are also outputting the name of the bucket that we are creating.

Let's install the npm packages we are using here.

{%change%} From the project root run the following.

``` bash
$ npx sst add-cdk @aws-cdk/aws-s3 @aws-cdk/aws-lambda
```

The reason we are using the [**add-cdk**](https://docs.serverless-stack.com/packages/cli#add-cdk-packages) command instead of using an `npm install`, is because of [a known issue with AWS CDK](https://docs.serverless-stack.com/known-issues). Using mismatched versions of CDK packages can cause some unexpected problems down the road. The `sst add-cdk` command ensures that we install the right version of the package.

## Using Sharp as a Layer

Next let's set up Sharp as a Layer.

{%change%} First create a new directory in your project root.

``` bash
$ mkdir -p layers/sharp
```

Then head over to this repo and download the latest `sharp-lambda-layer.zip` from the releases — [https://github.com/Umkus/lambda-layer-sharp/releases](https://github.com/Umkus/lambda-layer-sharp/releases)

Unzip that into the `layers/sharp` directory that we just created. Make sure that the path looks something like `layers/sharp/nodejs/node_modules`.

## Adding function code

Now in our function, we'll be handling resizing an image once it's uploaded.

{%change%} Add a new file at `src/resize.js` with the following.

``` js
import AWS from "aws-sdk";
import sharp from "sharp";
import stream from "stream";

const width = 400;
const prefix = `${width}w`;

const S3 = new AWS.S3();

// Read stream for downloading from S3
function readStreamFromS3({ Bucket, Key }) {
  return S3.getObject({ Bucket, Key }).createReadStream();
}

// Write stream for uploading to S3
function writeStreamToS3({ Bucket, Key }) {
  const pass = new stream.PassThrough();

  return {
    writeStream: pass,
    upload: S3.upload({
      Key,
      Bucket,
      Body: pass,
    }).promise(),
  };
}

// Sharp resize stream
function streamToSharp(width) {
  return sharp().resize(width);
}

export async function main(event) {
  const s3Record = event.Records[0].s3;

  // Grab the filename and bucket name
  const Key = s3Record.object.key;
  const Bucket = s3Record.bucket.name;

  // Check if the file has already been resized
  if (Key.startsWith(prefix)) {
    return false;
  }

  // Create the new filename with the dimensions
  const newKey = `${prefix}-${Key}`;

  // Stream to read the file from the bucket
  const readStream = readStreamFromS3({ Key, Bucket });
  // Stream to resize the image
  const resizeStream = streamToSharp(width);
  // Stream to upload to the bucket
  const { writeStream, upload } = writeStreamToS3({
    Bucket,
    Key: newKey,
  });

  // Trigger the streams
  readStream.pipe(resizeStream).pipe(writeStream);

  // Wait for the file to upload
  await upload;

  return true;
}
```

We are doing a few things here. Let's go over them in detail.

1. In the `main` function, we start by grabbing the `Key` or filename of the file that's been uploaded. We also get the `Bucket` or name of the bucket that it was uploaded to.
2. Check if the file has already been resized, by looking at the filename and if it starts with the dimensions. If it has, then we quit the function.
3. Generate the new filename with the dimensions.
4. Create a stream to read the file from S3, another to resize the image, and finally upload it back to S3. We use streams because really large files might hit the limit for what can be downloaded on to the Lambda function.
5. Finally, we start the streams and wait for the upload to complete.

Now let's install the npm packages we are using here.

{%change%} Run this from the root.

``` bash
$ npm install sharp aws-sdk
```

## Starting your dev environment

{%change%} SST features a [Live Lambda Development](https://docs.serverless-stack.com/live-lambda-development) environment that allows you to work on your serverless apps live.

``` bash
$ npx sst start
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
dev-bucket-image-resize-my-stack: deploying...

 ✅  dev-bucket-image-resize-my-stack


Stack dev-bucket-image-resize-my-stack
  Status: deployed
  Outputs:
    BucketName: dev-bucket-image-resize-my-stack-bucketd7feb781-k3myfpcm6qp1
```

## Uploading files

Now head over to the S3 page in your AWS console — [https://s3.console.aws.amazon.com/](https://s3.console.aws.amazon.com). Search for the bucket name from the above output.

![S3 bucket created with SST](/assets/examples/bucket-image-resize/s3-bucket-created-with-sst.png)

Here you can drag and drop an image to upload it.

![Drag and drop file to upload to S3](/assets/examples/bucket-image-resize/drag-and-drop-file-to-upload-to-s3.png)

Give it a minute after it's done uploading. Hit **Close** to go back to the list of files.

![Complete file upload to S3](/assets/examples/bucket-image-resize/complete-file-to-upload-to-s3.png)

You'll notice the resized image shows up.

![SST resized image in S3 bucket](/assets/examples/bucket-image-resize/sst-resized-image-in-s3-bucket.png)

## Making changes

Let's try making a quick change.

{%change%} Change the `width` in your `src/resize.js`.

``` bash
const width = 100;
```

Now if you go back and upload that same image again, you should see the new resized image show up in your S3 bucket.

![Updated SST resized image in S3 bucket](/assets/examples/bucket-image-resize/updated-sst-resized-image-in-s3-bucket.png)

## Deploying to prod

{%change%} To wrap things up we'll deploy our app to prod.

``` bash
$ npx sst deploy --stage prod
```
This allows us to separate our environments, so when we are working in `dev`, it doesn't break the API for our users.

## Cleaning up

Finally, you can remove the resources created in this example using the following commands.

``` bash
$ npx sst remove
$ npx sst remove --stage prod
```

Note that, by default resources like the S3 bucket are not removed automatically. To do so, you'll need to explicitly set it.

``` js
import { RemovalPolicy } from "@aws-cdk/core";

const bucket = new sst.Bucket(this, "Bucket", {
  s3Bucket: {
    // Delete all the files
    autoDeleteObjects: true,
    // Remove the bucket when the stack is removed
    removalPolicy: RemovalPolicy.DESTROY,
  },
  ...
}

```

## Conclusion

And that's it! We've got a completely serverless image resizer that automatically resizes any images uploaded to our S3 bucket. And we can test our changes locally before deploying to AWS! Check out the repo below for the code we used in this example. And leave a comment if you have any questions!

