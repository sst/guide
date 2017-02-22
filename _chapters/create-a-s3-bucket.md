---
layout: post
title: Create a S3 Bucket
date: 2017-02-06 00:00:00
---

To be able to host our note taking app, we need to upload the assets that are going to served out statically on S3. S3 has a concept of buckets (or folders) to separate different types of files.

A bucket can also be configured to host the assets in it as a static website and is automatically assigned a publicly accessible URL. So let's get started.

### Create Bucket

First, log in to your [AWS Console](https://console.aws.amazon.com) and select S3 from the list of services.

![Select S3 Service screenshot]({{ site.url }}/assets/select-s3-service.png)

Select **Create Bucket** and pick a name for your application and select the **US East** Region. Since our application is being served out using a CDN, the region should not matter to us.

![Create S3 Bucket screenshot]({{ site.url }}/assets/create-s3-bucket.png)

Step through the next steps and leave the defaults by clicking **Next**.

![Create S3 Bucket next properties screenshot]({{ site.url }}/assets/create-s3-bucket-next-properties.png)

![Create S3 Bucket next permissions screenshot]({{ site.url }}/assets/create-s3-bucket-next-permissions.png)

![Create S3 Bucket next review screenshot]({{ site.url }}/assets/create-s3-bucket-next-review.png)

Now click on your newly created bucket from the list and navigate to it's permissions by clicking **Permissions**.

![Select Bucket properties screenshot]({{ site.url }}/assets/select-bucket-permissions.png)

### Add Permissions

Buckets by defualt are not publicly accessible, so we need to change the permissions. Select the **Bucket Policy** from the permissions panel.

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

And finally we need to turn our bucket into a static website. Select the **Properties** tab from the top panel.

![Select properties tab screenshot]({{ site.url }}/assets/select-bucket-properties.png)

Select **Static website hosting**. 

![Select static web hosting screenshot]({{ site.url }}/assets/select-static-website-hosting.png)

Now select **Use this bucket to host a website** and add our `index.html` as the **Index Document** and the **Error Document**. Since we are letting React handle 404s, we can simply redirect our errors to our `index.html` as well. Hit **Save** once you are done.

This panel also shows us where our app will be accessible. AWS assigns us a URL for our static website. In this case the URL assigned to me is `notes-app-client.s3-website-us-east-1.amazonaws.com`.

![Edit static web hosting properties screenshot]({{ site.url }}/assets/edit-static-web-hosting-properties.png)

Now that our bucket is all setup and ready, let's go ahead and upload our assets to it.
