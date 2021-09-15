---
layout: post
title: Set Custom Domains Through Seed
date: 2018-03-15 00:00:00
lang: en
description: We will use the Seed console to configure our API Gateway endpoints in our serverless project with custom domains. To configure a stage with a custom domain go to the stage settings, select the Route 53 domain, a sub-domain, and the base path.
ref: set-custom-domains-through-seed
comments_id: set-custom-domains-through-seed/178
---

In the main part of our guide, we [used SST to configure custom domains for our serverless app]({% link _chapters/custom-domains-in-serverless-apis.md %}). But if you are using Serverless Framework or want to manage custom domains centrally, [Seed](https://seed.run) gives you another option.

Let's look at how.

We are still using the same custom domain that we purchased back in the [Purchase a Domain with Route 53]({% link _chapters/purchase-a-domain-with-route-53.md %}) chapter.

### Add Custom Domain on Seed

Head over to our app settings in Seed.

![Seed app pipeline screenshot](/assets/part2/seed-app-pipeline.png)

Here click on **Edit Custom Domains**.

![Click Edit Custom Domains in app settings screenshot](/assets/part2/click-edit-custom-domains-in-app-settings.png)

And click **Add** for our production endpoint.

![Click Add for production endpoint in custom domain settings](/assets/part2/click-add-for-production-endpoint-in-custom-domain-settings.png)

Seed will pull up any domains you have configured in [Route 53](https://aws.amazon.com/route53/).

Hit **Select a domain** and you should see a list of all your Route 53 domains. Select the one you intend to use. And fill in the sub-domain and base path. For example, you could use `api.my-domain.com/prod`; where `api` is the sub-domain and `prod` is the base path.

And hit **Add Custom Domain**.

![Click Add Custom Domain button for prod endpoint](/assets/part2/click-add-custom-domain-button-for-prod-endpoint.png)

Seed will now go through and configure the domain for this API Gateway endpoint, create the SSL certificate and attach it to the domain. This process can take up to 40 mins.

While we wait, we can do the same for our `dev` endpoint. Select the domain, sub-domain, and base path. In our case we'll use something like `api.my-domain.com/dev`.

![Click Add Custom Domain button for dev endpoint](/assets/part2/click-add-custom-domain-button-for-dev-endpoint.png)

Hit **Add Custom Domain** and wait for the changes to take place.

And that's it! Now your app is configured with custom domains on Seed.
