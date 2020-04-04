---
layout: post
title: Errors Outside Lambda Functions
date: 2017-01-24 00:00:00
lang: en
ref: errors-outside-lambda-functions
description: 
comments_id: 
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

