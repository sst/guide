---
layout: post
title: Custom Domains in serverless APIs
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are setting a custom domain for our serverless API on AWS. We are using the SST ApiGatewayV2 component to configure the custom domain.
ref: custom-domains-in-serverless-apis
comments_id: custom-domains-in-serverless-apis/2464
---

In the [previous chapter]({% link _chapters/purchase-a-domain-with-route-53.md %}) we purchased a new domain on [Route 53](https://aws.amazon.com/route53/){:target="_blank"}. Now let's use it for our serverless API.

{%change%} In your `infra/api.ts` add this above the `transform: {` line.

```ts
domain: $app.stage === "production" ? "<api.yourdomainhere.com>" : undefined,
```
{%note%}
Without specifying the API subdomain, the deployment will attempt to create duplicate A (IPv4) and AAAA (IPv6) DNS records and error.  
{%endnote%}

This tells SST that we want to use a custom domain **if** we are deploying to the `production` stage. We are not setting one for our `dev` stage, or any other stage.

We could for example, base it on the stage name, `api-${app.stage}.my-serverless-app.com`. So for `dev` it might be `api-dev.my-serverless-app.com`. But we'll leave that as an exercise for you.

The `$app` is a global variable that's available in our config. You can [learn more about it here]({{ site.sst_url }}/docs/reference/global/#app){:target="_blank"}.

### Deploy the App

Let's deploy these changes to prod.

{%change%} Run the following from **your project root**.

```bash
$ npx sst deploy --stage production
```

{%note%}
Deploying changes to custom domains can take a few minutes.
{%endnote%}

At the end of the deploy process you should see something like this.

```bash
+  Complete
   Api: https://api.my-serverless-app.com
   ...
```

This is great! We now have our app deployed to prod and our API has a custom domain.

Next, let's use our custom domain for our React app as well.
