---
layout: post
title: Purchase a Domain with Route 53
date: 2017-02-08 01:00:00
lang: en
description: To host our React.js app under our own domain name in AWS we are going to purchase a domain using Route 53.
comments_id: purchase-a-domain-with-route-53/1867
ref: purchase-a-domain-with-route-53
---

We want to host our React app on our own domain (and later our API as well). To do this, we'll start by purchasing a domain through AWS. We'll be using [Amazon Route 53](https://aws.amazon.com/route53/) for this.

If you are following this guide but are not ready to purchase a new domain, you can skip this chapter.

On the other hand, if you have an existing domain that is not on AWS, follow these docs to [move it over to Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html).

Let's get started. In your [AWS Console](https://console.aws.amazon.com) head over to the Route 53 section in the list of services.

![Select Route 53 service screenshot](/assets/select-route-53-service.png)

Type in your domain in the **Register domain** section and click **Check**.

![Search available domain screenshot](/assets/search-available-domain.png)

After checking its availability, click **Add to cart**.

![Add domain to cart screenshot](/assets/add-domain-to-cart.png)

And hit **Continue** at the bottom of the page.

![Continue to contact details screenshot](/assets/continue-to-contact-detials.png)

Fill in your contact details and hit **Continue** once again.

![Continue to confirm details screenshot](/assets/continue-to-confirm-detials.png)

Finally, review your details and confirm the purchase by hitting **Complete Purchase**.

![Confirm domain purchase screenshot](/assets/confirm-domain-purchase.png)

Next, let's use our new domain for the our site on Netlify.
