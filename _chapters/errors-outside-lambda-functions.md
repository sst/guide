---
layout: post
title: Upload a File to S3
date: 2017-01-24 00:00:00
lang: en
ref: upload-a-file-to-s3
description: We want users to be able to upload a file in our React.js app and add it as an attachment to their note. To upload files to S3 directly from our React.js app we are going to use AWS Amplify's Storage.put() method.
comments_id: comments-for-upload-a-file-to-s3/123
---

### Initialization Error

In `get.js`, add code:
```
import * as dynamoDbLib from "./dynamodb-lib";
```

You will get an error in Sentry that looks like this:

[ SCREENSHOT ]

### Handler Function Error

In `get.js`, add code:
```
export const main2 = debugHandler(async (event, context) => {
```

You will get an error in Sentry that looks like this:

[ SCREENSHOT ]

### Handler File Error

Rename `get.js` to `get2.js` temporarily:
```
mv get.js get2.js
```

You will get an error in Sentry that looks like this:

[ SCREENSHOT ]

