---
layout: post
title: Upload a File to S3
date: 2017-01-24 00:00:00
lang: en
ref: upload-a-file-to-s3
description: We want users to be able to upload a file in our React.js app and add it as an attachment to their note. To upload files to S3 directly from our React.js app we are going to use AWS Amplify's Storage.put() method.
comments_id: comments-for-upload-a-file-to-s3/123
---

Three type of errors:
- Errors in your Lambda function's business logic
- Errors in your Lambda function, but before business logic was run
- Errors in API Gateway, and Lambda was not invoked

