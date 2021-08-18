---
layout: post
title: Custom domains for React apps on AWS
date: 2021-08-17 00:00:00
lang: en
description: 
ref: custom-domains-for-react-apps-on-aws
comments_id: 
---

In the previous chapter we configured a custom domain for our serverless API. TODO: ADD LINK TO PREVIOUS CHAPTER. Now let's do the same for our frontend React.js app.

{%change%} In the `lib/FrontendStack.js` add the following below the `new sst.ReactStaticSite(` line.

``` js
customDomain: {
  domainName:
    scope.stage === "prod"
      ? "my-serverless-app.com"
      : `${scope.stage}.my-serverless-app.com`,
  domainAlias: scope.stage === "prod" ? "www.my-serverless-app.com" : undefined,
},
```

Just like the API case, we want to use the given custom domain **if** we are deploying to the `prod` stage. This means that when we are using our app locally, it won't be using the custom domain. Of course change this if you'd like to use a custom domain locally as well. You can use something like `dev.my-serverless-app.com`.

Just like the API, we want to use the custom domain `my-serverless-app.com` **if** we are deploying to the `prod` stage. For all other stages we want to base it on the stage name. So for `dev`, it'll be `dev.my-serverless-app.com`.

The `domainAlias` prop is necessary because we want visitors of `www.my-serverless-app.com` to be redirected to the URL we want to use. It's a good idea to support both the `www.` and root versions of our domain. You can switch these around so that the root domain redirects to the `www.` version as well.

We don't need to set the `domainAlias` for the non-prod versions because we don't need `www.` versions for those.

We need to use the custom domain URL of our API in our React app.

{%change%} Find the following line in `lib/FrontendStack.js`.

``` js
        REACT_APP_API_URL: api.url,
```

{%change%} And replace it with.

``` js
        REACT_APP_API_URL: api.customDomainUrl || api.url,
```

We also need to update the outputs of our frontend stack.

{%change%} Replace the `this.addOutputs` call at the bottom of `lib/FrontendStack.js`.

``` js
this.addOutputs({
  SiteUrl: site.customDomainUrl || site.url,
});
```

Here we are returning the custom domain URL, if we have one. If not, then we return the auto-generated URL.

### Deploy the app

Just like the previous chapter, we need to update these changes in prod.

{%change%} Run the following from your project root.

``` bash
$ npx sst deploy --stage prod
```

This command will take a few minutes. At the end of the deploy process you should see somehting like this.

``` bash
Stack prod-notes-frontend
  Status: no changes
  Outputs:
    SiteUrl: https://my-serverless-app.com
  ReactSite:
    REACT_APP_API_URL: https://api.my-serverless-app.com
```

And that's it! Our serverless app is now deployed to prod under our own domain!

TODO: SCREENSHOT ON CUSTOM DOMAIN

### Commit the Changes

{%change%} Let's commit our code so far and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Setting up custom domains"
$ git push
```

At this stage your serverless app is pretty much complete. In the next couple of optional sections we are going at how we can automate our deployments. We want to set it up so that when we `git push` our changes, our app should deploy automatically. We are also going to setup monitoring and error tracking.
