---
layout: post
title: Handle CORS in S3 for File Uploads
date: 2021-08-17 00:00:00
lang: en
ref: handle-cors-in-s3-for-file-uploads
description: In this chapter we'll look at how to configure CORS for an S3 bucket in our serverless app. We'll be adding these settings in our SST Bucket component.
comments_id: handle-cors-in-s3-for-file-uploads/2174
---

In the notes app we are building, users will be uploading files to the bucket we just created. And since our app will be served through our custom domain, it'll be communicating across domains while it does the uploads. By default, S3 does not allow its resources to be accessed from a different domain. However, [cross-origin resource sharing (CORS)](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing){:target="_blank"} defines a way for client web applications that are loaded in one domain to interact with resources in a different domain.

Similar to the [previous chapter]({% link _chapters/handle-cors-in-serverless-apis.md %}), the [`Bucket`]({{ site.sst_url }}/docs/component/aws/bucket/){:target="_blank"} component enables CORS by default.

```ts
new sst.aws.Bucket("Uploads", {
  // Enabled by default
  cors: true,
});
```

You can configure this further. [Read more about this here]({{ site.sst_url }}/docs/component/aws/bucket#cors){:target="_blank"}.

```ts
new sst.aws.Bucket("Uploads", {
  cors: {
    allowMethods: ["GET"]
  }
});
```

### Commit the Changes

{%change%} Let's commit our changes and push it to GitHub.

```bash
$ git add .
$ git commit -m "Enabling CORS"
$ git push
```

Now we are ready to use our serverless backend to create our frontend React app!
