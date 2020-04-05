---
layout: post
title: Errors in API Gateway
date: 2020-04-03 00:00:00
lang: en
description: 
comments_id: 
ref: errors-in-api-gateway
---

Your APIs can also fail before the request reaches the Lambda function. When failed, you will not see any request in the Lambda logs on Seed, since the Lambda functions were not invoked.

Two common causes are:
- Wrong API path
- Wrong API method

You can debug by looking at the error response from the API.

### Wrong API Path

Open `src/containers/Home.js` in your clients code, and locate the loadNotes() function. Change the API path to an invalid path.
```
...

  function loadNotes() {
    return API.get("notes", "/invalid_path");
  }

...
```

Head over to your notes app, and load the home page. You will notice the page fails with an error alert sayinig "Network Alert".

![SCREENSHOT](https://i.imgur.com/2aRFFYg.png)

What happens behind the scene is:
- the browser first make OPTIONS request to /invalid_path
- API Gateway returns a 403 response indicating the path is not found
- the browser does not continue to make the GET request

If you have API Access logs enabled on Seed, you can head over to Seed dashboard and click on search log.

![SCREENSHOT](https://i.imgur.com/GSTIKBX.png)

Search `debug api` and select the API access log

![SCREENSHOT](https://i.imgur.com/EoEuMrH.png)


Also you should see a OPTIONS request with path '/debug/invalid_path'. The request fails with 403 status code.

![SCREENSHOT](https://i.imgur.com/icxyKr4.png)


### Wrong API method

Open `src/containers/Home.js` in your clients code, and locate the loadNotes() function. Change the API method to put.
```
...

  function loadNotes() {
    return API.put("notes", "/notes");
  }

...
```

Head over to your notes app, and load the home page. You will notice the page fails with an error alert sayinig "Network Alert".

![SCREENSHOT](https://i.imgur.com/2aRFFYg.png)

The error looks similar, but what happens behind the scene is:
- the browser first make OPTIONS request to /notes
- API Gateway returns a successful 200 response with the HTTP methods allowed for the path
- the allowed HTTP methods are GET and POST. This is because we defined
  - GET request on /notes to list all the notes; and
  - POST request on /notes to create a new note
- the browser reports the error because the request method PUT is not allowed

In this case, you will only see an OPTIONS request in your access log, but not the PUT request.

![SCREENSHOT](https://i.imgur.com/2C3Uvz3.png)

