---
layout: post
title: Custom domains in serverless APIs
date: 2021-08-17 00:00:00
lang: en
description: 
ref: custom-domains-in-serverless-apis
comments_id: 
---

In the [previous chapter]({% link _chapters/purchase-a-domain-with-route-53.md %}) we purchased a new domain on [Route 53](https://aws.amazon.com/route53/). Now let's use that for our serverless API.

{%change%} In your `lib/ApiStack.js` add the following above the `defaultAuthorizationType: "AWS_IAM",` line.

``` js
customDomain:
  scope.stage === "prod" ? "api.my-serverless-app.com" : undefined,
```

This tells SST that we want to use the custom domain `api.my-serverless-app.com` **if** we are deploying to the `prod` stage. We are not setting one for our `dev` stage, or any other stage for that matter. We'll leave that as an exercise for you.

We could for example, base it on the stage name, `api-${scope.stage}.my-serverless-app.com`. So for `dev` it might be `api-dev.my-serverless-app.com`.

We also need to update the outputs of our API stack.

{%change%} Replace the `this.addOutputs` call at the bottom of `lib/ApiStack.js`.

``` js
this.addOutputs({
  ApiEndpoint: this.api.customDomainUrl || this.api.url,
});
```

Here we are returning the custom domain URL, if we have one. If not, then we return the auto-generated URL.

### Deploy the app

We are now going to deploy our app to prod. You can go ahead and stop the local development environments for SST and React.

{%change%} Run the following from your project root.

``` bash
$ npx sst deploy --stage prod
```

This command will take a few minutes as it'll deploy your app to a completely new environment. Recall that we are deploying to a separate prod environment because we don't want to affect our users while we are actively developing our app. This ensures that we have a separate local dev environment and a separate prod environment.

At the end of the deploy process you should see somehting like this.

``` bash
Stack prod-notes-api
  Status: no changes
  Outputs:
    ApiEndpoint: https://api.my-serverless-app.com
```

This is great! We now have our app deployed to prod with a custom domain.

Next, let's do the same for our React app as well.
