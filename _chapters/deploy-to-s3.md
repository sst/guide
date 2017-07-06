---
layout: post
title: Deploy to S3
date: 2017-02-07 00:00:00
description: To use our React.js app in production we are going to use Create React App’s build command to create a production build of our app. And to upload our React.js app to an S3 Bucket on AWS, we are going to use the AWS CLI s3 sync command. 
comments_id: 63
---

Now that our S3 Bucket is created we are ready to upload the assets of our app.

### Build Our App

Create React App comes with a convenient way to package and prepare our app for deployment. From our working directory simply run the following command.

``` bash
$ npm run build
```

This packages all of our assets and places them in the `build/` directory.

### Upload to S3

Now to deploy simply run the following command; where `YOUR_S3_DEPLOY_BUCKET_NAME` is the name of the S3 Bucket we created in the [Create an S3 bucket]({% link _chapters/create-an-s3-bucket.md %}) chapter.

``` bash
$ aws s3 sync build/ s3://YOUR_S3_DEPLOY_BUCKET_NAME
```

All this command does is that it syncs the `build/` directory with our bucket on S3. Just as a sanity check, go into the S3 section in your [AWS Console](https://console.aws.amazon.com/console/home) and check if your bucket has the files we just uploaded.

![Uploaded to S3 screenshot]({{ site.url }}/assets/uploaded-to-s3.png)

And our app should be live on S3! If you head over to the URL assigned to you (in my case it is [http://notes-app-client.s3-website-us-east-1.amazonaws.com](http://notes-app-client.s3-website-us-east-1.amazonaws.com)), you should see it live.

![App live on S3 screenshot]({{ site.url }}/assets/app-live-on-s3.png)

Next we'll configure CloudFront to serve our app out globally.
