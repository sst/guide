---
layout: post
title: Create an S3 Bucket for File Uploads
date: 2016-12-27 00:00:00
redirect_from: /chapters/create-a-s3-bucket-for-file-uploads.html
description: To allow users to upload files to our serverless app we are going to use Amazon S3 (Simple Storage Service). S3 allows you to store files and organize them into buckets. We are going to create an S3 bucket and enable CORS (cross-origin resource sharing) to ensure that our React.js app can upload files to it.
context: true
comments_id: create-an-s3-bucket-for-file-uploads/150
---

Now that we have our database table ready; let's get things set up for handling file uploads. We need to handle file uploads because each note can have an uploaded file as an attachment.

[Amazon S3](https://aws.amazon.com/s3/) (Simple Storage Service) provides storage service through web services interfaces like REST. You can store any object in S3 including images, videos, files, etc. Objects are organized into buckets, and identified within each bucket by a unique, user-assigned key.

In this chapter, we are going to create an S3 bucket which will be used to store user uploaded files from our notes app.

### Create Bucket

First, log in to your [AWS Console](https://console.aws.amazon.com) and select **S3** from the list of services.

![Select S3 Service screenshot](/assets/s3/select-s3-service.png)

Select **Create bucket**.

![Select Create Bucket screenshot](/assets/s3/select-create-bucket.png)

Pick a name of the bucket and select a region. Then select **Create**.

- **Bucket names** are globally unique, which means you cannot pick the same name as this tutorial.
- **Region** is the physical geographical region where the files are stored. We will use **US East (N. Virginia)** for this guide.

Make a note of the name and region as we'll be using it later in the guide.

![Enter S3 Bucket Info screenshot](/assets/s3/enter-s3-bucket-info.png)

Step through the next steps and leave the defaults by clicking **Next**, and then click **Create bucket** on the last step.

![Set S3 Bucket Properties screenshot](/assets/s3/set-s3-bucket-properties.png)
![Set S3 Bucket Permissions screenshot](/assets/s3/set-s3-bucket-permissions.png)
![Review S3 Bucket screenshot](/assets/s3/review-s3-bucket.png)

### Enable CORS

In the notes app we'll be building, users will be uploading files to the bucket we just created. And since our app will be served through our custom domain, it'll be communicating across domains while it does the uploads. By default, S3 does not allow its resources to be accessed from a different domain. However, cross-origin resource sharing (CORS) defines a way for client web applications that are loaded in one domain to interact with resources in a different domain. Let's enable CORS for our S3 bucket.

Select the bucket we just created.

![Select Created S3 Bucket screenshot](/assets/s3/select-created-s3-bucket.png)

Select the **Permissions** tab, then select **CORS configuration**.

![Select S3 Bucket CORS Configuration screenshot](/assets/s3/select-s3-bucket-cors-configuration.png)

Add the following CORS configuration into the editor, then hit **Save**.

``` xml
<CORSConfiguration>
	<CORSRule>
		<AllowedOrigin>*</AllowedOrigin>
		<AllowedMethod>GET</AllowedMethod>
		<AllowedMethod>PUT</AllowedMethod>
		<AllowedMethod>POST</AllowedMethod>
		<AllowedMethod>HEAD</AllowedMethod>
		<AllowedMethod>DELETE</AllowedMethod>
		<MaxAgeSeconds>3000</MaxAgeSeconds>
		<AllowedHeader>*</AllowedHeader>
	</CORSRule>
</CORSConfiguration>
```

Note that you can edit this configuration to use your own domain or a list of domains when you use this in production.

![Save S3 Bucket CORS Configuration screenshot](/assets/s3/save-s3-bucket-cors-configuration.png)

Now that our S3 bucket is ready, let's get set up to handle user authentication.
