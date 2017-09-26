---
layout: post
title: Create a CloudFront Distribution
date: 2017-02-08 00:00:00
description: To server out our React.js app hosted on Amazon S3 through a CDN we are going to use CloudFront. We will create a CloudFront Distribution and point it to our S3 Bucket. We are also going to enable Gzip compression using the “Compress Objects Automatically” setting in the AWS console. And to ensure that our React.js app responds with the right HTTP headers, we will create a Custom Error Response.
context: all
comments_id: 64
---

Now that we have our app up and running on S3, let's serve it out globally through CloudFront. To do this we need to create an AWS CloudFront Distribution.

Select CloudFront from the list of services in your [AWS Console](https://console.aws.amazon.com).

![Select AWS CloudFront service screenshot](/assets/select-cloudfront-service.png)

Then select **Create Distribution**.

![Create AWS CloudFront Distribution screenshot](/assets/create-cloudfront-distribution.png)

And then in the **Web** section select **Get Started**.

![Select get started web screenshot](/assets/select-get-started-web.png)

In the Create Distribution form we need to start by specifying the Origin Domain Name for our Web CloudFront Distribution. This field is pre-filled with a few options including the S3 bucket we created. But we are **not** going to select on the options in the dropdown. This is because the options here are the REST API endpoints for the S3 bucket instead of the one that is set up as a static website.

You can grab the S3 website endpoint from the **Static website hosting** panel for your S3 bucket. We had configured this in the previous chapter. Copy the URL in the **Endpoint** field.

![S3 static website domain screenshot](/assets/s3-static-website-domain.png)

And paste that URL in the **Origin Domain Name** field. In my case it is, `http://notes-app-client.s3-website-us-east-1.amazonaws.com`.

![Fill origin domain name field screenshot](/assets/fill-origin-domain-name-field.png)

And now scroll down the form and switch **Compress Objects Automatically** to **Yes**. This will automatically Gzip compress the files that can be compressed and speed up the delivery of our app.

![Select compress objects automatically screenshot](/assets/select-compress-objects-automatically.png)

Next, scroll down a bit further to set the **Default Root Object** to `index.html`.

![Set default root object screenshot](/assets/set-default-root-object.png)

And finally, hit **Create Distribution**.

![Hit create distribution screenshot](/assets/hit-create-distribution.png)

It takes AWS a little while to create a distribution. But once it is complete you can find your CloudFront Distribution by clicking on your newly created distribution from the list and looking up its domain name.

![AWS CloudFront Distribution doamin name screenshot](/assets/cloudfront-distribution-domain-name.png)

And if you navigate over to that in your browser, you should see your app live.

![App live on CloudFront screenshot](/assets/app-live-on-cloudfront.png)

Now before we move on there is one last thing we need to do. Currently, our static website returns our `index.html` as the error page. We set this up back in the chapter where we created our S3 bucket. However, it returns a HTTP status code of 404 when it does so. We want to return the `index.html` but since the routing is handled by React Router; it does not make sense that we return the 404 HTTP status code. One of the issues with this is that certain corporate firewalls and proxies tend to block 4xx and 5xx responses.

### Custom Error Responses

So we are going to create a custom error response and return a 200 status code instead. The downside of this approach is that we are going to be returning 200 even for cases where we don't have a route in our React Router. Unfortunately, there isn't a way around this. This is because CloudFront or S3 are not aware of the routes in our React Router.

To set up a custom error response, head over to the **Error Pages** tab in our Distribution.

![Error Pages in CloudFront screenshot](/assets/error-pages-in-cloudfront.png)

And select **Create Custom Error Response**.

![Select Create Custom Error Response in CloudFront screenshot](/assets/select-create-custom-error-response.png)

Pick **404** for the **HTTP Error Code** and select **Customize Error Response**. Enter `/index.html` for the **Response Page Path** and **200** for the **HTTP Response Code**.

![Create Custom Error Response screenshot](/assets/create-custom-error-response.png)

And hit **Create**. This is basically telling CloudFront to respond to any 404 responses from our S3 bucket with the `index.html` and a 200 status code. Creating a custom error response should take a couple of minutes to complete.

Next up, let's point our domain to our CloudFront Distribution.
