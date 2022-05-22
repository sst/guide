---
layout: post
title: Handle CORS in S3 for File Uploads
date: 2021-08-17 00:00:00
lang: en
ref: handle-cors-in-s3-for-file-uploads
description: In this chapter we'll look at how to configure CORS for an S3 bucket in our serverless app. We'll be adding these settings in our SST Bucket construct.
comments_id: handle-cors-in-s3-for-file-uploads/2174
---

In the notes app we are building, users will be uploading files to the bucket we just created. And since our app will be served through our custom domain, it'll be communicating across domains while it does the uploads. By default, S3 does not allow its resources to be accessed from a different domain. However, [cross-origin resource sharing (CORS)](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) defines a way for client web applications that are loaded in one domain to interact with resources in a different domain.

Let's enable CORS for our S3 bucket.

{%change%} Replace the following line in `stacks/StorageStack.js`.

```js
const bucket = new Bucket(stack, "Uploads");
```

{%change%} With this.

```js
const bucket = new Bucket(stack, "Uploads", {
  cors: [
    {
      maxAge: "1 day",
      allowedOrigins: ["*"],
      allowedHeaders: ["*"],
      allowedMethods: ["GET", "PUT", "POST", "DELETE", "HEAD"],
    },
  ],
});
```

Note that, you can customize this configuration to use your own domain or a list of domains. We'll use these default settings for now.

### Commit the Changes

{%change%} Let's commit our changes and push it to GitHub.

```bash
$ git add .
$ git commit -m "Enabling CORS"
$ git push
```

Now we are ready to use our serverless backend to create our frontend React app!
