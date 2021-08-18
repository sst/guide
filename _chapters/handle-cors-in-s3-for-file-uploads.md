---
layout: post
title: Handle CORS in S3 for File Uploads
date: 2021-08-17 00:00:00
lang: en 
ref: handle-cors-in-s3-for-file-uploads
description: 
comments_id: handle-cors-in-s3-for-file-uploads/2174
---

In the notes app we'll be building, users will be uploading files to the bucket we just created. And since our app will be served through our custom domain, it'll be communicating across domains while it does the uploads. By default, S3 does not allow its resources to be accessed from a different domain. However, cross-origin resource sharing (CORS) defines a way for client web applications that are loaded in one domain to interact with resources in a different domain. Let's enable CORS for our S3 bucket.

{%change%} Replace the following line in `lib/StorageStack.js`.

``` js
    this.bucket = new sst.Bucket(this, "Uploads");
```

{%change%} With this.

``` js
    this.bucket = new sst.Bucket(this, "Uploads", {
      s3Bucket: {
        // Allow client side access to the bucket from a different domain
        cors: [
          {
            maxAge: 3000,
            allowedOrigins: ["*"],
            allowedHeaders: ["*"],
            allowedMethods: ["GET", "PUT", "POST", "DELETE", "HEAD"],
          },
        ],
      },
    });
```

Note that, you can customize this configuration to use your own domain or a list of domains when you use this in production. We'll use these default settings for now.

### Commit the Changes

{%change%} Let's commit our backend code and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Enabling CORS"
$ git push
```

Now we are ready to use our serverless backend to create our frontend React app!

----

TODO: MOVE OLD SECTION

In the notes app we'll be building, users will be uploading files to the bucket we just created. And since our app will be served through our custom domain, it'll be communicating across domains while it does the uploads. By default, S3 does not allow its resources to be accessed from a different domain. However, cross-origin resource sharing (CORS) defines a way for client web applications that are loaded in one domain to interact with resources in a different domain. Let's enable CORS for our S3 bucket.

Go back to the AWS Console and head over to the S3 section. Then, select the bucket [we had previously created]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}).

![Select Created S3 Bucket screenshot](/assets/s3/select-created-s3-bucket.png)

Select the **Permissions** tab

![Select S3 Bucket Permissions tab](/assets/s3/select-s3-bucket-permissions-tab.png)

Then scroll down to the **Cross-origin resource sharing (CORS)** section and hit **Edit**.

![Scroll to S3 Bucket CORS Configuration screenshot](/assets/s3/scroll-to-s3-bucket-cors-configuration.png)

Paste the following CORS configuration into the editor, then hit **Save changes**.

``` json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "PUT",
            "POST",
            "HEAD",
            "DELETE"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [],
        "MaxAgeSeconds": 3000
    }
]
```

![Save S3 Bucket CORS Configuration screenshot](/assets/s3/save-s3-bucket-cors-configuration.png)

Note that, you can customize this configuration to use your own domain or a list of domains when you use this in production.

Now we are ready to use our Serverless backend to create our frontend React app!
