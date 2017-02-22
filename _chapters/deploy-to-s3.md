---
layout: post
title: Deploy to S3
date: 2017-02-07 00:00:00
---

Now that our S3 bucket is created we are ready to deploy our app.

### Build our app

Create React App comes with a convenient way to package and prepare our app for deployment. From our working directory simply run the following command.

{% highlight bash %}
npm run build
{% endhighlight %}

This packages all of our assets and places them in the `build/` directory.

### Upload to S3

Now to deploy simply run the following command; where `notes-app-client` is the name of the bucket we previously created.

{% highlight bash %}
aws s3 sync build/ s3://notes-app-client
{% endhighlight %}

All this command does is that it syncs the `build/` directory with our bucket on S3. Just as a sanity check, go into the S3 section in your [AWS Console](https://console.aws.amazon.com/console/home) and check if your bucket has the files we just uploaded.

![Uploaded to S3 screenshot]({{ site.url }}/assets/uploaded-to-s3.png)

And our app should be live on S3! If you head over to the URL assigned to you, in my case it is [http://notes-app-client.s3-website-us-east-1.amazonaws.com](http://notes-app-client.s3-website-us-east-1.amazonaws.com).

![App live on S3 screenshot]({{ site.url }}/assets/app-live-on-s3.png)

Next we'll configure CloudFront to serve our app out globally.
