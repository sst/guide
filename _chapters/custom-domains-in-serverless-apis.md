---
layout: post
title: Custom Domains in serverless APIs
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are setting a custom domain for our serverless API on AWS. We are using the SST Api construct to configure the custom domain.
ref: custom-domains-in-serverless-apis
comments_id: custom-domains-in-serverless-apis/2464
---

In the [previous chapter]({% link _chapters/purchase-a-domain-with-route-53.md %}) we purchased a new domain on [Route 53](https://aws.amazon.com/route53/). Now let's use it for our serverless API.

{%change%} In your `stacks/ApiStack.js` add the following above the `authorizer: "iam"` line.

```js
customDomain:
  app.stage === "prod" ? "api.my-serverless-app.com" : undefined,
```

This tells SST that we want to use the custom domain `api.my-serverless-app.com` **if** we are deploying to the `prod` stage. We are not setting one for our `dev` stage, or any other stage.

We could for example, base it on the stage name, `api-${app.stage}.my-serverless-app.com`. So for `dev` it might be `api-dev.my-serverless-app.com`. But we'll leave that as an exercise for you.

We also need to update the outputs of our API stack.

{%change%} Replace the `stack.addOutputs` call at the bottom of `stacks/ApiStack.js`.

```js
stack.addOutputs({
  ApiEndpoint: api.customDomainUrl || api.url,
});
```

Here we are returning the custom domain URL, if we have one. If not, then we return the auto-generated URL.

### Deploy the App

We are now going to deploy our app to prod. You can go ahead and stop the local development environments for SST and React.

{%change%} Run the following from your project root.

```bash
$ npx sst deploy --stage prod
```

This command will take a few minutes as it'll deploy your app to a completely new environment. Recall that we are deploying to a separate prod environment because we don't want to affect our users while we are actively developing our app. This ensures that we have a separate local dev environment and a separate prod environment.

At the end of the deploy process you should see something like this.

```bash
Stack prod-notes-ApiStack
  Status: no changes
  Outputs:
    ApiEndpoint: https://api.my-serverless-app.com
```

This is great! We now have our app deployed to prod and our API has a custom domain.

Next, let's use our custom domain for our React app as well.
