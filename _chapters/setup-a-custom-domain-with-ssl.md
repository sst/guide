---
layout: post
title: Set up a Custom Domain With SSL
date: 2017-02-08 02:00:00
lang: en
description: We want to create a custom domain for our React.js app that is hosted on AWS. We also want to enable SSL or HTTPS. To do so, we are going to use Route 53 and request a certificate using the Certificate Manager service from AWS.
comments_id: chapter-comments-set-up-ssl/1868
redirect_from: /chapters/setup-ssl.html
ref: setup-a-custom-domain-with-ssl
---

Now that our CloudFront Distribution has been created. Let's configure it with a custom domain and setup SSL.

### Setup a New Domain

Let's start by setting up your custom domain.

1. If you have an existing domain that is not on AWS, follow these docs to [move it over to Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/MigratingDNS.html).
2. If you'd like to pruchase a new Route 53 domain, you can follow the step in this chapter — [Purchase a Domain with Route 53]({% link _chapters/purchase-a-domain-with-route-53.md %})

### Setup SSL

Now that we have our domain, request a certificate to enable us to use SSL or HTTPS with our domain. AWS makes this fairly easy to do, thanks to Certificate Manager.

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

Next up, we'll associate our domain and its certificate with our CloudFront Distribution.
