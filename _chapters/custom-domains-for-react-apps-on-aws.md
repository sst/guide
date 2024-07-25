---
layout: post
title: Custom Domains for React Apps on AWS
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are setting a custom domain for our React.js app on AWS. We are using the SST StaticSite component to configure the custom domain.
ref: custom-domains-for-react-apps-on-aws
comments_id: custom-domains-for-react-apps-on-aws/2463
---

In the [previous chapter we configured a custom domain for our serverless API]({% link _chapters/custom-domains-in-serverless-apis.md %}). Now let's do the same for our frontend React app.

{%change%} In the `infra/web.ts` add the following above the `environment: {` line.

```ts
domain:
  $app.stage === "production"
    ? {
        name: "<yourdomainhere.com>",
        redirects: ["www.<yourdomainhere.com>"],
      }
    : undefined,
```

Just like the API case, we want to use our custom domain **if** we are deploying to the `production` stage. This means that when we are using our app locally or deploying to any other stage, it won't be using the custom domain.

Of course, you can change this if you'd like to use a custom domain for the other stages. You can use something like `${app.stage}.my-serverless-app.com`. So for `dev` it'll be `dev.my-serverless-app.com`. But we'll leave this as an exercise for you.

The `redirects` prop is necessary because we want visitors of `www.my-serverless-app.com` to be redirected to the URL we want to use. It's a good idea to support both the `www.` and root versions of our domain. You can switch these around so that the root domain redirects to the `www.` version as well. 

You won't need to set the `redirects` for the non-prod versions because we don't need `www.` versions for those.

### Deploy the App

Just like the previous chapter, we need to update these changes in prod.

{%change%} Run the following from your project root.

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
   Frontend: https://my-serverless-app.com
   ...
```

And that's it! Our React.js app is now deployed to prod under our own domain!

![App update live screenshot](/assets/part2/app-update-live.png)

### Commit the Changes

{%change%} Let's commit our code so far and push it to GitHub.

```bash
$ git add .
$ git commit -m "Setting up custom domains"
$ git push
```

At this stage our full-stack serverless app is pretty much complete. In the next couple of optional sections we are going at how we can automate our deployments. We want to set it up so that when we `git push` our changes, our app should deploy automatically.
