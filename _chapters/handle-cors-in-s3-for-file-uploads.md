---
layout: post
title: Handle CORS in S3 for File Uploads
date: 2020-10-26 00:00:00
lang: en 
ref: handle-cors-in-s3-for-file-uploads
description: In this chapter we'll be configuring CORS (or cross-origin resource sharing) for our AWS S3 bucket. This will allow the users of our React web app to upload files directly to our S3 bucket. Even though they'll be hosted on two different domains.
comments_id: handle-cors-in-s3-for-file-uploads/2174
---

In the notes app we'll be building, users will be uploading files to the bucket we just created. And since our app will be served through our custom domain, it'll be communicating across domains while it does the uploads. By default, S3 does not allow its resources to be accessed from a different domain. However, cross-origin resource sharing (CORS) defines a way for client web applications that are loaded in one domain to interact with resources in a different domain. Let's enable CORS for our S3 bucket.

Go back to the AWS Console and head over to the S3 section. Then, select the bucket [we had previously created]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}).

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

![Save S3 Bucket CORS Configuration screenshot](/assets/s3/save-s3-bucket-cors-configuration.png)

Note that, you can customize this configuration to use your own domain or a list of domains when you use this in production.

Now we are ready to use our Serverless backend to create our frontend React app!
