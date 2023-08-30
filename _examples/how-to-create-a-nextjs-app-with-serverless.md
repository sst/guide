---
layout: example
title: How to create a Next.js app with serverless
short_title: Next.js
date: 2021-09-17 00:00:00
lang: en
index: 2
type: webapp
description: In this example we will look at how to deploy a full-stack Next.js app to your AWS account with SST and OpenNext. We'll also compare the various deployment options for Next.js.
short_desc: Full-stack Next.js app with DynamoDB.
repo: quickstart-nextjs
ref: how-to-create-a-nextjs-app-with-serverless
comments_id: how-to-create-a-next-js-app-with-serverless/2486
---

In this example we will look at how to deploy a full-stack [Next.js](https://nextjs.org) app to your AWS account with [OpenNext](https://open-next.js.org) and the [`NextjsSite`]({{ site.docs_url }}/constructs/NextjsSite) construct.

## Requirements

- Node.js 16 or later
- We'll be using TypeScript
- An [AWS account]({% link _chapters/create-an-aws-account.md %}) with the [AWS CLI configured locally]({% link _chapters/configure-the-aws-cli.md %})

## Create a Next.js app

{%change%} Let's start by creating a Next.js app. We'll just go with the defaults.

```bash
$ npx create-next-app@latest
```

## Initialize SST in your app

{%change%} Initialize SST in your Next.js app by running this in the root.

```bash
$ npx create-sst@latest
$ npm install
```

This will detect that you are trying to configure a Next.js app. It'll add a `sst.config.ts` and a couple of packages to your `package.json`.

```js
import { SSTConfig } from "sst";
import { NextjsSite } from "sst/constructs";

export default {
  config(_input) {
    return {
      name: "quickstart-nextjs",
      region: "us-east-1",
    };
  },
  stacks(app) {
    app.stack(function Site({ stack }) {
      const site = new NextjsSite(stack, "site");

      stack.addOutputs({
        SiteUrl: site.url,
      });
    });
  },
} satisfies SSTConfig;
```

The `stacks` code describes the infrastructure of your serverless app. SST uses [AWS CDK]({% link _chapters/what-is-aws-cdk.md %}).

You are **ready to deploy** your Next.js app at this point! But for the purpose of this example, we'll go a bit further and add a file uploads feature to our app.

## Start the dev environment

{%change%} Let's start our SST dev environment.

```bash
$ npx sst dev
```

SST features a [Live Lambda Development]({{ site.docs_url }}/live-lambda-development) environment that allows you to work on your serverless apps live. This will ask you to start your Next.js dev environment as well.

{%change%} Start Next.js locally in a separate terminal.

```bash
$ npm run dev
```

This will run `sst bind next dev`. More on bind later.

## Create our infrastructure

To support file uploads in our app, we need an S3 bucket. Let's add that.

### Add the table

{%change%} Add the following above our `NextjsSite` definition in the `sst.config.ts`.

```typescript
const bucket = new Bucket(stack, "public");
```

Here we are using the [`Bucket`]({{ site.docs_url }}/constructs/Bucket) construct to create an S3 bucket.

{%change%} Add it to the imports.

```diff
- import { NextjsSite } from "sst/constructs";
+ import { Bucket, NextjsSite } from "sst/constructs";
```

### Bind it to our app

We want our Next.js app to be able to access our bucket.

{%change%} Add this to our Next.js definition in the `sst.config.ts`.

```diff
- const site = new NextjsSite(stack, "site");
+ const site = new NextjsSite(stack, "site", {
+   bind: [bucket],
+ });
```

We'll see what bind does below.

## Support file uploads

Now to let our users upload files in our Next.js app we need to start by generating a presigned URL. This is a temporary URL that our frontend can make a request to upload files.

### Generate a presigned URL

{%change%} Add this to `pages/index.ts` above the `Home` component.

```typescript
export async function getServerSideProps() {
  const command = new PutObjectCommand({
    ACL: "public-read",
    Key: crypto.randomUUID(),
    Bucket: Bucket.public.bucketName,
  });
  const url = await getSignedUrl(new S3Client({}), command);

  return { props: { url } };
}
```

This generates a presigned URL when our app loads. Note how we can access our S3 bucket in a typesafe way — `Bucket.public.bucketName`. [You can learn more about Resource Binding over on our docs]({{ site.docs_url }}/resource-binding).

{%change%} We need to install a couple of packages.

```bash
$ npm install @aws-sdk/client-s3 @aws-sdk/s3-request-presigner
```

{%change%} And add these to the imports.

```typescript
import crypto from "crypto";
import { Bucket } from "sst/node/bucket";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
```

### Add an upload form

Now let's add the form.

{%change%} Replace the `Home` component in `pages/index.tsx` with.

```tsx
export default function Home({ url }: { url: string }) {
  return (
    <main>
      <form
        onSubmit={async (e) => {
          e.preventDefault();

          const file = (e.target as HTMLFormElement).file.files?.[0]!;

          const image = await fetch(url, {
            body: file,
            method: "PUT",
            headers: {
              "Content-Type": file.type,
              "Content-Disposition": `attachment; filename="${file.name}"`,
            },
          });

          window.location.href = image.url.split("?")[0];
        }}
      >
        <input name="file" type="file" accept="image/png, image/jpeg" />
        <button type="submit" className={inter.className}>
          Upload
        </button>
      </form>
    </main>
  );
}
```

## Test your app

Now if you flip over to your browser, you should be able to upload an image and it'll redirect to it!

![Upload a file to S3 in Next.js app](/assets/examples/nextjs-app/upload-a-file-to-s3-in-next-js-app.png)

## Deploy to AWS

{%change%} To wrap things up we'll deploy our app to prod.

```bash
$ npx sst deploy --stage prod
```

This allows us to separate our environments, so when we are working in our local environment, it doesn't break the app for our users. You can stop the `npm run dev` command that we had previously run.

Once deployed, you should see your app's URL.

```bash
SiteUrl: https://dq1n2yr6krqwr.cloudfront.net
```

If you head over to the `URL` in your browser, you should see your new Next.js app in action!

![Deployed Next.js app with SST](/assets/examples/nextjs-app/deployed-next-js-app-with-sst.png)

We can [add a custom domain]({{ site.docs_url }}/custom-domains) to our app but we'll leave that as an exercise for later.

### Cleaning up

Finally, you can remove the resources created in this example using the following commands.

```bash
$ npx sst remove
$ npx sst remove --stage prod
```

---

## Comparisons

In this example we looked at how to use SST to deploy a Next.js app to AWS. But there are a few different ways to deploy Next.js apps. Let's look at how they all compare.

- [Vercel](https://vercel.com) is the most popular way to deploy Next.js apps. It's the most expensive and isn't open source.

- [Amplify](https://docs.amplify.aws/guides/hosting/nextjs/q/platform/js/) in many ways is AWS's version of Vercel. It's cheaper and deploys to your AWS account. But their implementation is incomplete and not on par with Vercel. And because they are not open source, you'll need to file a support ticket to get your issues fixed.

- [Serverless Next.js (sls-next) Component](https://github.com/serverless-nextjs/serverless-next.js) is open source and deploys to your AWS account. But this project is not being maintained anymore.

- [SST]({{ site.sst_github_repo }}) is completely open source and deploys directly to your AWS account. It uses [OpenNext](https://open-next.js.org) — an open-source serverless adapter for Next.js. The OpenNext project is a community effort to reverse engineer Vercel's implementation and make it available to everybody.

We hope this example has helped you deploy your Next.js apps to AWS. And given you an overview of all the deployment options out there.
