---
layout: post
title: Set up SSL
date: 2017-02-11 00:00:00
description: Tutorial on how to add HTTPS support for your React.js single page application hosted on S3 using AWS Certificate Manager.
---

Now that our app is being served through our domain, let's add a layer of security to it by switching to HTTPS. AWS makes this fairly easy to do, thanks to Certificate Manager.

### Request a Certificate

Select **Certificate Manager** from the list of services in your [AWS Console](https://console.aws.amazon.com).

![Select Certificate Manager service screenshot]({{ site.url }}/assets/select-certificate-manager-service.png)

Hit **Request a certificate** from the top and type in the name of our domain. Hit **Add another name to this certificate** and add our www version of our domain as well. Hit **Review and request** once you are done.

![Add domain names to certificate screenshot]({{ site.url }}/assets/add-domain-names-to-certificate.png)

On the next screen review to make sure you filled in the right domain names and hit **Confirm and request**.

![Review domain name details screenshot]({{ site.url }}/assets/review-domain-name-details.png)

And finally on the **Validation** screen, AWS let's you know which email addresses it's going to send emails to verify that it is your domain. Hit **Continue**, to send the verification emails.

![Validation for domains screenshot]({{ site.url }}/assets/validation-for-domains.png)

Now since we are setting up a certificate for two domains (the non-www and www versions), we'll be receiving two emails with a link to verify that you own the domains. Make sure to hit **I Approve** on both the emails.

![Domain verification screen screenshot]({{ site.url }}/assets/domain-verification.png)

Next, we'll associate this certificate with our CloudFront Distributions.

### Update CloudFront Distributions with Certificate

Open up our first CloudFront Distribution from our list of distributions and hit the **Edit** button.

![Select CloudFront Distribution screenshot]({{ site.url }}/assets/select-cloudfront-Distribution.png)

Now switch the **SSL Certificate** to **Custom SSL Certificate** and select the certificate we just created from the drop down. And scroll down to the bottom and hit **Yes, Edit**.

![Select custom SSL Certificate screenshot]({{ site.url }}/assets/select-custom-ssl-certificate.png)

Next, head over to the **Behaviors** tab from the top.

![Select Behaviors tab screenshot]({{ site.url }}/assets/select-behaviors-tab.png)

And select the only one we have and hit **Edit**.

![Edit Distribution Behavior screenshot]({{ site.url }}/assets/edit-distribution-behavior.png)

Then switch the **Viewer Protocol Policy** to **Redirect HTTP to HTTPS**. And scroll down to the bottom and hit **Yes, Edit**.

![Switch Viewer Protocol Policy screenshot]({{ site.url }}/assets/switch-viewer-protocol-policy.png)

Now let's do the same for our other CloudFront Distribution.

![Select custom SSL Certificate screenshot]({{ site.url }}/assets/select-custom-ssl-certificate-2.png)

![Switch Viewer Protocol Policy screenshot]({{ site.url }}/assets/switch-viewer-protocol-policy-2.png)

And that's it. Our app should be served out on our domain through HTTPS.

![App live with certificate screenshot]({{ site.url }}/assets/app-live-with-certificate.png)

Next up, let's look at the process of deploying updates to our app.
