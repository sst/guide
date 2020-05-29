---
layout: post
title: Purchase a Domain with Route 53
date: 2017-02-08 01:00:00
lang: en
description: To host our React.js app under our own domain name in AWS we are going to purchase a domain using Route 53.
comments_id: purchase-a-domain-with-route-53/1867
ref: purchase-a-domain-with-route-53
---

Now that we have our CloudFront distribution live, let's set up our domain with it. You can purchase a domain right from the [AWS Console](https://console.aws.amazon.com) by heading to the Route 53 section in the list of services.

![Select Route 53 service screenshot](/assets/select-route-53-service.png)

### Purchase a Domain with Route 53

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

Next up, we'll set up SSL to make sure we can use HTTPS with our domain.
