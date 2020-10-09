---
layout: post
title: Set Custom Domains Through Seed
date: 2018-03-15 00:00:00
lang: en
description: We will use the Seed console to configure our API Gateway endpoints in our Serverless project with custom domains. To configure a stage with a custom domain go to the stage settings, select the Route 53 domain, a sub-domain, and the base path.
ref: set-custom-domains-through-seed
comments_id: set-custom-domains-through-seed/178
---

Our serverless API uses API Gateway and it gives us some auto-generated endpoints. We would like to configure them to use a scheme like `api.my-domain.com` or something similar. This can take a few different steps through the AWS Console, but it is pretty straightforward to configure through [Seed](https://seed.run).

To start with, we need to purchase a domain on [Amazon Route 53](https://aws.amazon.com/route53/). If you have an existing domain not on AWS, follow these docs to [move it over to Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html).

### Purchase a Domain with Route 53

Head over to your [AWS Console](https://console.aws.amazon.com) and select **Route 53** in the list of services.

![Select Route 53 service screenshot](/assets/part2/select-route-53-service.png)

Type in your domain in the **Register domain** section and click **Check**.

![Search available domain screenshot](/assets/part2/search-available-domain.png)

After checking its availability, click **Add to cart**.

![Add domain to cart screenshot](/assets/part2/add-domain-to-cart.png)

And hit **Continue** at the bottom of the page.

![Continue to contact details screenshot](/assets/part2/continue-to-contact-detials.png)

Fill in your contact details and hit **Continue** once again.

![Continue to confirm details screenshot](/assets/part2/continue-to-confirm-detials.png)

Finally, review your details and confirm the purchase by hitting **Complete Purchase**.

![Confirm domain purchase screenshot](/assets/part2/confirm-domain-purchase.png)

Next, let's use this custom domain for our app.

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

Now that we've automated our deployments, let’s do a quick test to see what will happen if we make a mistake and push some faulty code to production.
