---
layout: post
title: Custom Domains for React Apps on AWS
date: 2021-08-17 00:00:00
lang: en
description: In this chapter we are setting a custom domain for our React.js app on AWS. We are using the SST ReactStaticSite construct to configure the custom domain.
ref: custom-domains-for-react-apps-on-aws
comments_id: custom-domains-for-react-apps-on-aws/2463
---

In the [previous chapter we configured a custom domain for our serverless API]({% link _chapters/custom-domains-in-serverless-apis.md %}). Now let's do the same for our frontend React.js app.

{%change%} In the `lib/FrontendStack.js` add the following below the `new sst.ReactStaticSite(` line.

``` js
customDomain:
  scope.stage === "prod"
    ? {
        domainName: "my-serverless-app.com",
        domainAlias: "wwww.my-serverless-app.com",
      }
    : undefined,
```

Just like the API case, we want to use our custom domain **if** we are deploying to the `prod` stage. This means that when we are using our app locally or deploying to any other stage, it won't be using the custom domain.

Of course, you can change this if you'd like to use a custom domain for the other stages. You can use something like `${scope.stage}.my-serverless-app.com`. So for `dev` it'll be `dev.my-serverless-app.com`. But we'll leave this as an exercise for you.

The `domainAlias` prop is necessary because we want visitors of `www.my-serverless-app.com` to be redirected to the URL we want to use. It's a good idea to support both the `www.` and root versions of our domain. You can switch these around so that the root domain redirects to the `www.` version as well.

You won't need to set the `domainAlias` for the non-prod versions because we don't need `www.` versions for those.

We need to use the custom domain URL of our API in our React app.

{%change%} Find the following line in `lib/FrontendStack.js`.

``` js
REACT_APP_API_URL: api.url,
```

{%change%} And replace it with.

``` js
REACT_APP_API_URL: api.customDomainUrl || api.url,
```

Note that, if you are going to use a custom domain locally, you might need to remove your app (`npx sst remove`) and deploy it again. This is because CDK doesn't allow you to change these references dynamically.

We also need to update the outputs of our frontend stack.

{%change%} Replace the `this.addOutputs` call at the bottom of `lib/FrontendStack.js` with this.

``` js
this.addOutputs({
  SiteUrl: site.customDomainUrl || site.url,
});
```

Here, we are returning the custom domain URL, if we have one. If not, then we return the auto-generated URL.

### Deploy the App

Just like the previous chapter, we need to update these changes in prod.

{%change%} Run the following from your project root.

``` bash
$ npx sst deploy --stage prod
```

This command will take a few minutes. At the end of the deploy process you should see something like this.

``` bash
Stack prod-notes-frontend
  Status: no changes
  Outputs:
    SiteUrl: https://my-serverless-app.com
  ReactSite:
    REACT_APP_API_URL: https://api.my-serverless-app.com
```

And that's it! Our React.js app is now deployed to prod under our own domain!

![React app hosted on custom domain](/assets/part2/react-app-hosted-on-custom-domain.png)

### Commit the Changes

{%change%} Let's commit our code so far and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Setting up custom domains"
$ git push
```

At this stage our full-stack serverless app is pretty much complete. In the next couple of optional sections we are going at how we can automate our deployments. We want to set it up so that when we `git push` our changes, our app should deploy automatically. We are also going to setup monitoring and error tracking.
