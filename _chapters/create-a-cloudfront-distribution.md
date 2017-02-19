---
layout: post
title: Create a CloudFront Distribution
---

Now that we our app up and running on S3, let's serve it out globally through CloudFront. To do this we need to create a CloudFront Distribution.

Select CloudFront from the list of services in your [AWS Console](https://console.aws.amazon.com).

![Select CloudFront service screenshot]({{ site.url }}/assets/select-cloudfront-service.png)

Then select **Create Distribution**.

![Create CloudFront Distribution screenshot]({{ site.url }}/assets/create-cloudfront-distribution.png)

And then in the **Web** section select **Get Started**.

![Select get started web screenshot]({{ site.url }}/assets/select-get-started-web.png)

In the Create Distribution form we need to start by specifying the Origin Domain Name for our Web CloudFront Distribution. This field is pre-filled with a few options including the S3 bucket we created. But we are **not** going to selct on the options in the dropdown. This is because the options here are the REST API endpoints for the S3 bucket instead of the one that is setup as a static website.

![S3 static website domain screenshot]({{ site.url }}/assets/s3-static-website-domain.png)

Now copy and paste that URL in the **Origin Domain Name** field. In our case it is, `http://notes-app-client.s3-website-us-east-1.amazonaws.com`.

![Fill origin domain name field screenshot]({{ site.url }}/assets/fill-origin-domain-name-field.png)

And now scroll down the form and switch **Compress Objects Automatically** to **Yes**. This will automatically Gzip compress the files that can be compressed.

![Select compress objects automatically screenshot]({{ site.url }}/assets/select-compress-objects-automatically.png)

Next, scroll down a bit further to set the **Default Root Object** to `index.html`.

![Set default root object screenshot]({{ site.url }}/assets/set-default-root-object.png)

And finally, hit **Create Distribution**.

![Hit create distribution screenshot]({{ site.url }}/assets/hit-create-distribution.png)

It takes AWS a little while to create a distribution. But once it is complete you can find your CloudFront Distribution by clicking on your newly created distribution from the list and looking up it's domain name.

![CloudFront Distribution doamin name screenshot]({{ site.url }}/assets/cloudfront-distribution-domain-name.png)

And if you navigate over to that in your browser, you should see your app live.

![App live on CloudFront screenshot]({{ site.url }}/assets/app-live-on-cloudfront.png)

Next up let's point our domain to our CloudFront Distribution.
