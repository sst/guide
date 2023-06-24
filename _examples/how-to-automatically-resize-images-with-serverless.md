---
layout: example
title: How to automatically resize images with serverless
short_title: Resize Images
date: 2021-02-08 00:00:00
lang: en
index: 4
type: async
description: In this example we will look at how to automatically resize images that are uploaded to your S3 bucket using SST. We'll be using the Bucket construct and a Lambda layer to set this up.
short_desc: Automatically resize images uploaded to S3.
repo: bucket-image-resize
ref: how-to-automatically-resize-images-with-serverless
comments_id: how-to-automatically-resize-images-with-serverless/2399
---

In this example we will look at how to automatically resize images that are uploaded to your S3 bucket using [SST]({{ site.sst_github_repo }}). We'll be using the [Sharp](https://github.com/lovell/sharp) package as a [Lambda Layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html).

We'll be using SST's [Live Lambda Development]({{ site.docs_url }}/live-lambda-development). It allows you to make changes and test locally without having to redeploy.

Here is a video of it in action.

<div class="video-wrapper">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/1m9Pl4oZBnw" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

## Requirements

- Node.js 16 or later
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create an SST app

{%change%} Let's start by creating an SST app.

```bash
$ npx create-sst@latest --template=base/example bucket-image-resize
$ cd bucket-image-resize
$ npm install
```

By default, our app will be deployed to the `us-east-1` AWS region. This can be changed in the `sst.config.ts` in your project root.

```js
import { SSTConfig } from "sst";

export default {
  config(_input) {
    return {
      name: "bucket-image-resize",
      region: "us-east-1",
    };
  },
} satisfies SSTConfig;
```

## Project layout

An SST app is made up of two parts.

1. `stacks/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `stacks/` directory of your project. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}), to create the infrastructure.

2. `packages/functions/` — App Code

   The code that's run when your API is invoked is placed in the `packages/functions/` directory of your project.

## Creating the bucket

Let's start by creating a bucket.

{%change%} Replace the `stacks/ExampleStack.ts` with the following.

```ts
import { Bucket, StackContext } from "sst/constructs";
import * as lambda from "aws-cdk-lib/aws-lambda";

export function ExampleStack({ stack }: StackContext) {
  // Create a new bucket
  const bucket = new Bucket(stack, "Bucket", {
    notifications: {
      resize: {
        function: {
          handler: "packages/functions/src/resize.main",
          nodejs: {
            esbuild: {
              external: ["sharp"],
            },
          },
          layers: [
            new lambda.LayerVersion(stack, "SharpLayer", {
              code: lambda.Code.fromAsset("layers/sharp"),
            }),
          ],
        },
        events: ["object_created"],
      },
    },
  });

  // Allow the notification functions to access the bucket
  bucket.attachPermissions([bucket]);

  // Show the endpoint in the output
  stack.addOutputs({
    BucketName: bucket.bucketName,
  });
}
```

This creates a S3 bucket using the [`Bucket`]({{ site.docs_url }}/constructs/Bucket) construct.

We are subscribing to the `OBJECT_CREATED` notification with a [`Function`]({{ site.docs_url }}/constructs/Function). The image resizing library that we are using, [Sharp](https://github.com/lovell/sharp), needs to be compiled specifically for the target runtime. So we are going to use a [Lambda Layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html) to upload it. Locally, the `sharp` package is not compatible with how our functions are bundled. So we are marking it in the `external`.

Finally, we are allowing our functions to access the bucket by calling `attachPermissions`. We are also outputting the name of the bucket that we are creating.

## Using Sharp as a Layer

Next let's set up Sharp as a Layer.

{%change%} First create a new directory in your project root.

```bash
$ mkdir -p layers/sharp
```

Then head over to this repo and download the latest `sharp-lambda-layer.zip` from the releases — [https://github.com/Umkus/lambda-layer-sharp/releases](https://github.com/Umkus/lambda-layer-sharp/releases)

Unzip that into the `layers/sharp` directory that we just created. Make sure that the path looks something like `layers/sharp/nodejs/node_modules`.

## Adding function code

Now in our function, we'll be handling resizing an image once it's uploaded.

{%change%} Add a new file at `packages/functions/src/resize.ts` with the following.

```ts
import sharp from "sharp";
import stream from "stream";

import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { Upload } from "@aws-sdk/lib-storage";

const width = 400;
const prefix = `${width}w`;

const S3 = new S3Client({});

// Read stream for downloading from S3
async function readStreamFromS3({
  Bucket,
  Key,
}: {
  Bucket: string;
  Key: string;
}) {
  const commandPullObject = new GetObjectCommand({
    Bucket,
    Key,
  });
  const response = await S3.send(commandPullObject);

  return response;
}

// Write stream for uploading to S3
function writeStreamToS3({ Bucket, Key }: { Bucket: string; Key: string }) {
  const pass = new stream.PassThrough();
  const upload = new Upload({
    client: S3,
    params: {
      Bucket,
      Key,
      Body: pass,
    },
  });

  return {
    writeStream: pass,
    upload,
  };
}

// Sharp resize stream
function streamToSharp(width: number) {
  return sharp().resize(width);
}

import { S3Handler } from "aws-lambda";

export const main: S3Handler = async (event) => {
  const s3Record = event.Records[0].s3;

  // Grab the filename and bucket name
  const Key = s3Record.object.key;
  const Bucket = s3Record.bucket.name;

  // Check if the file has already been resized
  if (Key.startsWith(prefix)) {
    return;
  }

  // Create the new filename with the dimensions
  const newKey = `${prefix}-${Key}`;

  // Stream to read the file from the bucket
  const readStream = await readStreamFromS3({ Key, Bucket });
  // Stream to resize the image
  const resizeStream = streamToSharp(width);
  // Stream to upload to the bucket
  const { writeStream, upload } = writeStreamToS3({
    Bucket,
    Key: newKey,
  });

  // Trigger the streams
  (readStream?.Body as NodeJS.ReadableStream)
    .pipe(resizeStream)
    .pipe(writeStream);

  try {
    // Wait for the file to upload
    await upload.done();
  } catch (err) {
    console.log(err);
  }
};
```

We are doing a few things here. Let's go over them in detail.

1. In the `main` function, we start by grabbing the `Key` or filename of the file that's been uploaded. We also get the `Bucket` or name of the bucket that it was uploaded to.
2. Check if the file has already been resized, by looking at the filename and if it starts with the dimensions. If it has, then we quit the function.
3. Generate the new filename with the dimensions.
4. Create a stream to read the file from S3, another to resize the image, and finally upload it back to S3. We use streams because really large files might hit the limit for what can be downloaded on to the Lambda function.
5. Finally, we start the streams and wait for the upload to complete.

Now let's install the npm packages we are using here.

{%change%} Run this command in the `packages/functions/` folder.

```bash
$ npm install sharp @aws-sdk/client-s3 @aws-sdk/lib-storage
```

## Starting your dev environment

{%change%} SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live.

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
dev-bucket-image-resize-ExampleStack: deploying...

 ✅  dev-bucket-image-resize-ExampleStack


Stack dev-bucket-image-resize-ExampleStack
  Status: deployed
  Outputs:
    BucketName: dev-bucket-image-resize-ExampleStack-bucketd7feb781-k3myfpcm6qp1
```

## Uploading files

Now head over to the **Buckets** tab in [SST Console](https://console.sst.dev). The SST Console is a web based dashboard to manage your SST apps. [Learn more about it in our docs]({{ site.docs_url }}/console).

Note, The Buckets explorer allows you to manage the S3 Buckets created with the **Bucket** constructs in your app. It allows you upload, delete, and download files. You can also create and delete folders.

![S3 bucket created with SST](/assets/examples/bucket-image-resize/s3-bucket-created-with-sst.png)

Here you can click **Upload** and select an image to upload it. After uploading you'll notice the resized image shows up.

![Drag and drop file to upload to S3](/assets/examples/bucket-image-resize/file-upload-to-s3.png)

Now refresh your console to see the resized image.

![SST resized image in S3 bucket](/assets/examples/bucket-image-resize/sst-resized-image-in-s3-bucket.png)

## Making changes

Let's try making a quick change.

{%change%} Change the `width` in your `packages/functions/src/resize.ts`.

```bash
const width = 100;
```

Now if you go back to SST console and upload that same image again, you should see the new resized image show up in your Buckets explorer.

![Updated SST resized image in S3 bucket](/assets/examples/bucket-image-resize/updated-sst-resized-image-in-s3-bucket.png)

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

Note that, by default resources like the S3 bucket are not removed automatically. To do so, you'll need to explicitly set it.

```ts
import * as cdk from "aws-cdk-lib";

const bucket = new Bucket(stack, "Bucket", {
  cdk: {
    bucket: {
      autoDeleteObjects: true,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    },
  },
  ...
}

```

## Conclusion

And that's it! We've got a completely serverless image resizer that automatically resizes any images uploaded to our S3 bucket. And we can test our changes locally before deploying to AWS! Check out the repo below for the code we used in this example. And leave a comment if you have any questions!
