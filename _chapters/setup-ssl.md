---
layout: post
title: Set up SSL
date: 2017-02-11 00:00:00
description: We want to enable SSL or HTTPS for our React.js app on AWS. To do so we are going to request a certificate using the Certificate Manager service from AWS. We are then going to use the new certificate in our CloudFront Distributions.
context: true
comments_id: comments-for-set-up-ssl/133
---

Now that our app is being served through our domain, let's add a layer of security to it by switching to HTTPS. AWS makes this fairly easy to do, thanks to Certificate Manager.

### Request a Certificate

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

Next, we'll associate this certificate with our CloudFront Distributions.

### Update CloudFront Distributions with Certificate

Open up our first CloudFront Distribution from our list of distributions and hit the **Edit** button.

![Select CloudFront Distribution screenshot](/assets/select-cloudfront-Distribution.png)

Now switch the **SSL Certificate** to **Custom SSL Certificate** and select the certificate we just created from the drop down. And scroll down to the bottom and hit **Yes, Edit**.

![Select custom SSL Certificate screenshot](/assets/select-custom-ssl-certificate.png)

Next, head over to the **Behaviors** tab from the top.

![Select Behaviors tab screenshot](/assets/select-behaviors-tab.png)

And select the only one we have and hit **Edit**.

![Edit Distribution Behavior screenshot](/assets/edit-distribution-behavior.png)

Then switch the **Viewer Protocol Policy** to **Redirect HTTP to HTTPS**. And scroll down to the bottom and hit **Yes, Edit**.

![Switch Viewer Protocol Policy screenshot](/assets/switch-viewer-protocol-policy.png)

Now let's do the same for our other CloudFront Distribution.

![Select custom SSL Certificate screenshot](/assets/select-custom-ssl-certificate-2.png)

But leave the **Viewer Protocol Policy** as **HTTP and HTTPS**. This is because we want our users to go straight to the HTTPS version of our non-www domain. As opposed to redirecting to the HTTPS version of our www domain before redirecting again.

![Dont switch Viewer Protocol Policy for www distribution screenshot](/assets/dont-switch-viewer-protocol-policy-for-www-distribution.png)

### Update S3 Redirect Bucket

The S3 Redirect Bucket that we created in the last chapter is redirecting to the HTTP version of our non-www domain. We should switch this to the HTTPS version to prevent the extra redirect.

Open up the S3 Redirect Bucket we created in the last chapter. Head over to the **Properties** tab and select **Static website hosting**.

![Open S3 Redirect Bucket Properties screenshot](/assets/open-s3-redirect-bucket-properties.png)

Change the **Protocol** to **https** and hit **Save**.

![Change S3 Redirect to HTTPS screenshot](/assets/change-s3-redirect-to-https.png)

And that's it. Our app should be served out on our domain through HTTPS.

![App live with certificate screenshot](/assets/app-live-with-certificate.png)

Next up, let's look at the process of deploying updates to our app.
