---
layout: post
title: Create a S3 Bucket
---

To be able to host our note taking app, we need to upload the assets that are going to served out statically on S3. S3 has a concept of buckets (or folders) to separate different types of files.

A bucket can also be configured to host the assets in it as a static website and is automatically assigned a publicly accessible URL. So let's get started.

### Create Bucket

First, log in to your [AWS Console](https://console.aws.amazon.com) and select S3 from the list of services.

![Select S3 Service screenshot]({{ site.url }}/assets/select-s3-service.png)

Select **Create Bucket** and pick a name for your application and select the **US Standard** Region. Since our application is being served out using a CDN, the region should not matter to us and US Standard ends up working better with our workflow.

![Create S3 Bucket screenshot]({{ site.url }}/assets/create-s3-bucket.png)

Now click on your newly created bucket from the list and navigate to it's properties.

![Select Bucket properties screenshot]({{ site.url }}/assets/select-bucket-properties.png)

### Add Permissions

Buckets by defualt are not publicly accessible, so we need to change the permissions. Select the **Permissions** panel from the left and click on **Add bucket policy**.

![Add bucket policy screenshot]({{ site.url }}/assets/add-bucket-policy.png)

Add the following bucket policy into the editor. Where `notes-app-client` is the name of our S3 bucket.

{% highlight json %}
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadForGetBucketObjects",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::notes-app-client/*"
      ]
    }
  ]
}
{% endhighlight %}

![Save bucket policy screenshot]({{ site.url }}/assets/save-bucket-policy.png)

And hit **Save**.

### Enable Static Web Hosting

And finally we need to turn our bucket into a static website. To do this, we need to select **Static Web Hosting** panel in the properties.

![Select static web hosting screenshot]({{ site.url }}/assets/select-static-website-hosting.png)

Now select **Enable website hosting** and add our `index.html` as the **Index Document** and the **Error Document**. Since we are letting React handle 404s, we can simply redirect our errors to our `index.html` as well. Hit save once you are done.

This panel also shows us where our app will be accessible. AWS assigns us a URL for our static website. In this case the URL assigned to me is `notes-app-client.s3-website-us-east-1.amazonaws.com`.

![Edit static web hosting properties screenshot]({{ site.url }}/assets/edit-static-web-hosting-properties.png)

Now that our bucket is all setup and ready, let's go ahead and upload our assets to it.
