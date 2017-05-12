---
layout: post
title: Set up WWW Domain Redirect
date: 2017-02-10 00:00:00
description: Tutorial on how to create a www domain redirect using S3 redirect, CloudFront, and AWS Route 53.
comments_id: 66
---

There's plenty of debate over the www vs non-www domains and while both sides have merit; we'll go over how to set up another domain (in this case the www) and redirect it to our original. If you prefer having the www domain as the default simply swap this step with the last one where we created a bare domain (non-www).

To create a new domain and have it redirect we are going to use the redirection feature that S3 Buckets have. So let's start by creating a new S3 redirect Bucket for this.

### Create S3 Redirect Bucket

Create a new S3 Bucket through the [AWS Console](https://console.aws.amazon.com). The name doesn't really matter but it pick something that helps us distinguish between the two.

![Create S3 Redirect Bucket screenshot]({{ site.url }}/assets/create-s3-redirect-bucket.png)

Next just follow through the steps and leave the defaults intact.

![Use defaults to create S3 redirect bucket screenshot]({{ site.url }}/assets/use-defaults-to-create-bucket.png)

Now go into the **Properties** of the new bucket and click on the **Static website hosting**.

![Select static website hosting screenshot]({{ site.url }}/assets/select-static-website-hosting-2.png)

But unlike last time we are going to select the **Redirect requests** option and fill in the domain we are going to be redirecting towards. This is the domain that we set up in our last chapter.

Also, make sure to copy the **Endpoint** as we'll be needing this later.

![Select redirect requests screenshot]({{ site.url }}/assets/select-redirect-requests.png)

And hit **Save** to make the changes. Next we'll create a CloudFront Distribution to point to this S3 redirect Bucket.

### Create a CloudFront Distribution

Create a new CloudFront Distribution. And copy the S3 **Endpoint** from the step above as the **Origin Domain Name**. Make sure to **not** use the one from the dropdown. In my case, it is `http://www-notes-app-client.s3-website-us-east-1.amazonaws.com`.

![Set origin domain name screenshot]({{ site.url }}/assets/set-origin-domain-name.png)

Scroll down to the **Alternate Domain Names (CNAMEs)** and use the www version of our domain name here.

![Set alternate domain name screenshot]({{ site.url }}/assets/set-alternate-domain-name-2.png)

Finally, we'll point our www domain to this CloudFront Distribution.

### Point WWW Domain to CloudFront Distribution

Head over to your domain in Route 53 and hit **Create Record Set**.

![Select Create Record Set screenshot]({{ site.url }}/assets/select-create-record-set-2.png)

This time fill in `www` as the **Name** and select **Alias** as **Yes**. And pick your new CloudFront Distribution from the **Alias Target** dropdown.

![Fill in record set detials screenshot]({{ site.url }}/assets/fill-in-record-set-details.png)

### Add IPv6 Support

Just as before, we need to add an AAAA record to support IPv6.

Create a new Record Set with the exact same settings as before, except make sure to pick **AAAA - IPv6 address** as the **Type**.

![Fill in AAAA IPv6 record set details screenshot]({{ site.url }}/assets/fill-in-aaaa-ipv6-record-set-details.png)

And that's it! Just give it some time for the DNS to propagate and if you visit your www version of your domain, it should redirect you to your non-www version.

Next, we'll set up SSL and add HTTPS support for our domains.
