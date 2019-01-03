---
layout: post
title: Set Custom Domains Through Seed
date: 2018-03-15 00:00:00
description: We will use the Seed console to configure our API Gateway endpoints in our Serverless project with custom domains. To configure a stage with a custom domain go to the stage settings, select the Route 53 domain, a sub-domain, and the base path.
context: true
comments_id: set-custom-domains-through-seed/178
---

Our serverless API uses API Gateway and it gives us some auto-generated endpoints. We would like to configure them to use a scheme like `api.my-domain.com` or something similar. This can take a few different steps through the AWS Console, but it is pretty straightforward to configure through [Seed](https://seed.run).

From our **prod** stage, click on **View Resources**.

![Prod stage view deployment screenshot](/assets/part2/prod-stage-view-deployment.png)

This shows you a list of the API endpoints and Lambda functions that are a part of this deployment. Now click on **Settings**.

![Prod stage deployment screenshot](/assets/part2/prod-stage-deployment.png)

And hit **Update Custom Domain**.

![Custom domain panel prod screenshot](/assets/part2/custom-domain-panel-prod.png)

In the first part of the tutorial we had added our domain to Route 53. If you haven't done so you can [read more about it here](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html). Hit **Select a domain** and you should see a list of all your Route 53 domains. Select the one you intend to use. And fill in the sub-domain and base path. For example, you could use `api.my-domain.com/prod`; where `api` is the sub-domain and `prod` is the base path.

And hit **Update**.

![Custom domain details prod screenshot](/assets/part2/custom-domain-details-prod.png)

Seed will now go through and configure the domain for this API Gateway endpoint, create the SSL certificate and attach it to the domain. This process can take up to 40 mins.

While we wait, we can do the same for our `dev` stage. Go into the **dev** stage > click **View Deployment** > click **Settings** > and hit **Update Custom Domain**. And select the domain, sub-domain, and base path. In our case we'll use something like `api.my-domain.com/dev`.

![Custom domain details dev screenshot](/assets/part2/custom-domain-details-dev.png)

Hit **Update** and wait for the changes to take place.

Once complete, we are ready to test our fully-configured serverless API backend!
