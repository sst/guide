---
layout: post
title: Set up Your Domain with CloudFront
date: 2017-02-09 00:00:00
lang: en
description: To host our React.js app under our own domain name in AWS we are going to purchase a domain using Route 53. Using the Certificate Manager service from AWS, we will request a certificate so we can enable HTTPS for our app. We will add our domain and its certificate to our CloudFront Distribution. We will point the domain to our CloudFront Distribution with an Alias Resource Record Set. We also need to create an AAAA Record Set to support IPv6.
comments_id: set-up-your-domain-with-cloudfront/149
ref: set-up-your-domain-with-cloudfront
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

Next, we'll add an alternate domain name for our CloudFront Distribution.

### Set up SSL for your Domain

Now that we have our domain, let's make sure we can serve it over HTTPS by setting up SSL. AWS makes this fairly easy to do, thanks to Certificate Manager.

Select **Certificate Manager** from the list of services in your [AWS Console](https://console.aws.amazon.com). Ensure that you are in the **US East (N. Virginia)** region. This is because a certificate needs to be from this region for it to [work with CloudFront](http://docs.aws.amazon.com/acm/latest/userguide/acm-regions.html). 

![Select Certificate Manager service screenshot](/assets/select-certificate-manager-service.png)

If this is your first certificate, you'll need to hit **Get started**. If not then hit **Request a certificate** from the top.

![Get started with Certificate Manager screenshot](/assets/get-started-certificate-manager.png)

And type in the name of our domain. Hit **Add another name to this certificate** and add our www version of our domain as well. Hit **Review and request** once you are done.

![Add domain names to certificate screenshot](/assets/add-domain-names-to-certificate.png)

Now to confirm that we control the domain, select the **DNS validation** method and hit **Review**.

![Select dns validation for certificate screenshot](/assets/select-dns-validation-for-certificate.png)

On the validation screen expand the two domains we are trying to validate.

![Expand dns validation details screenshot](/assets/expand-dns-validation-details.png)

Since we control the domain through Route 53, we can directly create the DNS record through here by hitting **Create record in Route 53**.

![Create Route 53 dns record screenshot](/assets/create-route-53-dns-record.png)

And confirm that you want the record to be created by hitting **Create**.

![Confirm Route 53 dns record screenshot](/assets/confirm-route-53-dns-record.png)

Also, make sure to do this for the other domain.

The process of creating a DNS record and validating it can take around 30 minutes.

Next, we'll associate this our domain and its certificate with our CloudFront Distribution.

### Add Alternate Domain for CloudFront Distribution

Head over to the details of your CloudFront Distribution and hit **Edit**.

![Edit CloudFront Distribution screenshot](/assets/edit-cloudfront-distribution.png)

And type in your new domain name in the **Alternate Domain Names (CNAMEs)** field.

![Set alternate domain name screenshot](/assets/set-alternate-domain-name.png)

Now switch the **SSL Certificate** to **Custom SSL Certificate** and select the certificate we just created from the drop down. And scroll down to the bottom and hit **Yes, Edit**.

![Select custom SSL Certificate screenshot](/assets/select-custom-ssl-certificate.png)

Scroll down and hit **Yes, Edit** to save the changes.

![Yes edit CloudFront changes screenshot](/assets/yes-edit-cloudfront-changes.png)

Next, head over to the **Behaviors** tab from the top.

![Select Behaviors tab screenshot](/assets/select-behaviors-tab.png)

And select the only one we have and hit **Edit**.

![Edit Distribution Behavior screenshot](/assets/edit-distribution-behavior.png)

Then switch the **Viewer Protocol Policy** to **Redirect HTTP to HTTPS**. And scroll down to the bottom and hit **Yes, Edit**.

![Switch Viewer Protocol Policy screenshot](/assets/switch-viewer-protocol-policy.png)

Next, let's point our domain to the CloudFront Distribution.

### Point Domain to CloudFront Distribution

Head back into Route 53 and hit the **Hosted Zones** button. If you don't have an existing **Hosted Zone**, you'll need to create one by adding the **Domain Name** and selecting **Public Hosted Zone** as the **Type**.

![Select Route 53 hosted zones screenshot](/assets/select-route-53-hosted-zones.png)

Select your domain from the list and hit **Create Record Set** in the details screen.

![Select create record set screenshot](/assets/select-create-record-set.png)

Leave the **Name** field empty since we are going to point our bare domain (without the www.) to our CloudFront Distribution.

![Leave name field empty screenshot](/assets/leave-name-field-empty.png)

And select **Alias** as **Yes** since we are going to simply point this to our CloudFront domain.

![Set Alias to yes screenshot](/assets/set-alias-to-yes.png)

In the **Alias Target** dropdown, select your CloudFront Distribution.

![Select your CloudFront Distribution screenshot](/assets/select-your-cloudfront-distribution.png)

Finally, hit **Create** to add your new record set.

![Select create to add record set screenshot](/assets/select-create-to-add-record-set.png)

### Add IPv6 Support

CloudFront Distributions have IPv6 enabled by default and this means that we need to create an AAAA record as well. It is set up exactly the same way as the Alias record.

Create a new Record Set with the exact settings as before, except make sure to pick **AAAA - IPv6 address** as the **Type**.

![Select AAAA IPv6 record set screenshot](/assets/select-create-aaaa-ipv6-record-set.png)

And hit **Create** to add your AAAA record set.

It can take around an hour to update the DNS records but once it's done, you should be able to access your app through your domain.

![App live on new domain screenshot](/assets/app-live-on-new-domain.png)

Next up, we'll take a quick look at ensuring that our www. domain also directs to our app.