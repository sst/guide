---
layout: post
title: Custom Domains for API Gateway
date: 2017-05-30 00:00:00
description:
comments_id:
---

Our serverless API uses API Gateway and it gives us some auto-generated endpoints. We would like to configure them to use a scheme like `api.my-domain.com` or something similar. This can take a few different steps through the AWS Console, but it is pretty straightforward through [Seed](https://seed.run).

From our project page on Seed, click on **prod**.

- Screenshot

Click on **View Deployment**.

- Screenshot

This shows you a list of the API endpoints and Lambda functions that are a part of this deployment. Now click on **Settings**.

- Screenshot

And hit **Update Custom Domain**.

- Screenshot

In the first part of the tutorial we had added our domain to Route 53. If you haven't done so you can [read more about it here](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html). If you hit **Select a domain**.

- Screenshot

You should see a list of all your Route 53 domains. Select the one you intend to use. And fill in the sub-domain and base path. For example, you could use `api.my-domain.com/prod`; where `api` is the sub-domain and `prod` is the base path.

- Screenshot

And hit **Update**.

- Screenshot

Seed will now go through and configure the domain for this API Gateway endpoint, create the SSL certificate and attach it to the domain. This process can take up to 40 mins.

While we wait, we can do the same for our `dev` stage. Go into the **dev** stage > click **View Deployment** > click **Settings** > and hit **Update Custom Domain**. And select the domain, sub-domain, and base path. In our case we'll use something like `api.mu-domain.com/dev`.

- Screenshot

Hit **Update** and wait for the changes to take place.

Now we are ready to test our fully-configured serverless API backend!
