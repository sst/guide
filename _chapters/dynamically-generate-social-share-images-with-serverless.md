---
layout: post
title: Dynamically generate social share images with serverless
date: 2021-06-25 00:00:00
lang: en
description: 
ref: dynamically-generate-social-share-images-with-serverless
comments_id: 
---

In this chapter we'll look at how to dynamically generate social share images or open graph (OG) images with serverless.

Social cards or social share images or open graph images are preview images that are disaplyed in social media sites like Facebook, Twitter, etc. when a link is posted. These images give users better context on what the link is about. They also look nicer than a logo or favicon.

However, creating a unique image for each blog post or page of your website can be time consuming and impractical. So we ideally want to be able to generate these images dynamically based on the title of the blog post or page and some other accompanying information.

We wanted to do something like this for Serverless Stack. And this is a perfect usecase for serverless. These images will be generated when your website is shared and it doesn't make sense to run a server to serve these out. So we built our own social cards service with [SST](/) and we deploy and manage it with [Seed](https://seed.run). 

For instance, here is what the social card for one of our chapters looks like.

SCREENSHOT OF SOCIAL CARD OF CHAPTER

We also have multiple templates to generate these social cards. Here's one from our [docs site]({{ site.docs_url }}) for our [StaticSite construct]({{ site.docs_url }}/constructs/StaticSite).

SCREENSHOT OF SOCIAL CARD OF STATICSITE DOCS

These images are served out of our social cards service. It's built using [Serverless Stack (SST)](/) and is hosted on AWS:

```
https://social-cards.serverless-stack.com
```

In this chapter we'll look at how we created this service and how you can do the same!

### Resources

The entire social cards service is open source and available on GitHub. So you can fork and play around with everything that will be talked about in this chapter.

- [Social Cards Service on GitHub](https://github.com/serverless-stack/social-cards)

### Table of Contents

In this chapter we'll be looking at how to:

1. The architecture of our social cards service
1. Create a serverless app with SST
2. Design tempaltes for our social cards in the browser
4. Use Puppeteer to take screenshots of the templates
5. Cache the images in an S3 bucket
6. Use CloudFront as a CDN to serve the images
7. Add a custom domain for our social cards service
8. Deploy and manage our social cards service
9. Integrate with static site generators

Let's start by taking a step back and getting a sense of the architecture of our social card service. 

### The Architecture

Our social cards service is a serverless app deployed to AWS.

ARCHITECTURE DIAGRAM

There are a couple of key parts to this and we'll look at it in detail below.

1. We have CloudFront as our CDN to serve out images.
2. CloudFront connects to our serverless API.
3. The API is powered by a Lambda function.
1. The Lambda function that will be generating these images.
   - It includes the templates that we'll be using. These are HTML files that are included in our Lambda function.
   - We'll run headless Chrome instance with [Puppeteer](https://developers.google.com/web/tools/puppeteer) and pass in the parameters for the templates.
   - We'll load these templates and take a screenshot.
   - We'll store these images in an S3 bucket and serve them out.
   - Finally, for any requests, the Lambda function will check the S3 bucket first to see if we've previously generated these images.

### Create an SST App

We'll start by creating a new SST app.

``` bash
$ npx create-serverless-stack@latest social-cards
$ cd social-cards
```

The infrastrure in our app is defined using [CDK]({% link _chapters/what-is-aws-cdk.html %}). Currently we just have a simple API that invokes a Lambda function.

You can see this in `lib/MyStack.js`.

``` js
// Create a HTTP API
const api = new sst.Api(this, "Api", {
  routes: {
    "GET /": "src/lambda.handler",
  },
});
```

For now our Lambda function in `src/lambda.js` just prints out _"Hello World"_.

### Design Social Card Templates

The first step is to create a template for our social share images. These HTML files will be loaded locally and we'll pass in the parameters for our template via the query string.

Let's look at the blog template that we use in Serverless Stack as an example.

SCREENSHOT OF BLOG TEMPLATE ON A LOCAL URL

The HTML that generates this page looks like:

``` html
<html>
  <head>
    <link rel="stylesheet" href="assets/css/reset.css">
    <link rel="stylesheet" href="assets/css/fonts.css">
    <link rel="stylesheet" href="assets/css/main.css">
    <link rel="stylesheet" href="assets/css/blog.css">
  </head>
  <body>
    <img class="logo" height="55" src="assets/images/logo.svg" />
    <span class="section">Blog</span>
    <div class="spacer">
      <h1 id="title"></h1>
      <div class="profile">
        <img id="avatar" width="64" src="" />
        <span id="author"></span>
      </div>
    </div>
    <a>Read Post</a>
    <script>
      const urlSearchParams = new URLSearchParams(window.location.search);
      const params = Object.fromEntries(urlSearchParams.entries());

      document.getElementById("title").innerHTML = params.title;
      document.getElementById("author").innerHTML = params.author;
      document.getElementById("avatar").src = `assets/images/profiles/${params.avatar}.png`;
    </script>
  </body>
</html>
```

Note the `<script>` tag at the bottom. It takes the querystring parameters and applies it to our HTML.

[Head over to the repo](https://github.com/serverless-stack/social-cards/blob/main/templates/serverless-stack-blog.html) to check out the rest of the files included in this template.

The recommended size for a social share image is `1200x630`. So we want to make sure we style our page accordingly.

We'll add these to the `templates/` directory in our project.

You can open these files locally with the URL:

```
file:///Users/jayair/Desktop/social-cards-service/templates/serverless-stack-blog.html?title=This%20is%20a%20sample%20blog%20post%20on%20Serverless%20Stack&author=Jay&avatar=jay
```

It has the format:

```
file:///Users/jayair/Desktop/social-cards-service/templates/serverless-stack-blog.html?title={title}&author={name}&avatar={filename}
```

In the repo you'll also notice we have a few other templates that we use. You can do someting similar. Just make sure that each template can read from the querystring and apply the parameters.

### Take Screenshots With Puppeteer

Now that our templates can load locally in a browser, let's create screenshot these templates and return an image in our Lambda function.

To do so we'll be using [Puppeteer](https://developers.google.com/web/tools/puppeteer). We'll need to install a couple of NPM packages.

``` bash
$ npm install puppeteer puppeteer-core chrome-aws-lambda
```

Here are the relevant parts of our Lambda function.

``` js
import path from "path";
import chrome from "chrome-aws-lambda";

const ContentType = "image/png";

const puppeteer = chrome.puppeteer;

export async function handler(event) {
  const pathParameters = parsePathParameters(event.pathParameters.path);

  const { title, options, template } = pathParameters;

  const browser = await puppeteer.launch({
    args: chrome.args,
    executablePath: await chrome.executablePath,
  });

  const page = await browser.newPage();

  await page.setViewport({
    width: 1200,
    height: 630,
  });

  // Navigate to the url
  await page.goto(
    `file:${path.join(
      process.cwd(),
      `templates/${template}.html`
    )}?title=${title}&${options}`
  );

  // Wait for page to complete loading
  await page.evaluate("document.fonts.ready");

  // Take screenshot
  const buffer = await page.screenshot();

  return {
    statusCode: 200,
    // Return as binary data
    isBase64Encoded: true,
    body: buffer.toString("base64"),
    headers: { "Content-Type": ContentType },
  };
}

/**
 * Route patterns to match:
 *
 * /$template/$title.png
 * /$template/$options/$title.png
 *
 * Returns an object with:
 *
 * { template, options, title }
 *
 */
function parsePathParameters(path) {
  let parts = path.split("/");

  if (parts.length !== 2 && parts.length !== 3) {
    return null;
  }

  if (parts.length === 2) {
    parts = [parts[0], null, parts[1]];
  }

  if (!parts[2].endsWith(".png")) {
    return null;
  }

  const encodedTitle = parts[2].replace(/\.png$/, "");
  const buffer = Buffer.from(encodedTitle, "base64");

  return {
    template: parts[0],
    options: parts[1] ? parseOptions(parts[1]) : "",
    title: decodeURIComponent(buffer.toString("ascii")),
  };
}
```

Let's look at what we are doing here.

1. We start by parsing the request URI. We'll be using this to later save our files to S3, so we'd l
