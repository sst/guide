---
layout: blog
title: Testing in SST
author: jay
image: assets/social-cards/sst-testing.png
---

You can write tests for your SST apps using the new [`sst load-config`]({{ site.docs_url }}/packages/cli#load-config) CLI. It auto-loads secrets and config for your tests.

Meaning that it'll load the [`Config`]({% link _posts/2022-08-22-config.md %}) of your app, but for your tests.

So for example, this command loads your `Config` and runs your tests using [Vitest](https://vitest.dev).

```bash
$ sst load-config -- vitest run
```

Also, make sure to [check out our launch announcement for `Config`]({% link _posts/2022-08-22-config.md %}) in case you missed it.

We updated the [`create sst`]({{ site.docs_url }}/packages/create-sst) GraphQL starter to include the updated `npm test` script.

```js
"test": "sst load-config -- vitest run"
```

We also have a [new chapter in our docs dedicated to testing]({{ site.docs_url }}/advanced/testing). It includes how to write tests for the different parts of your app:

- Tests for your domain code. Recall that we recommend [Domain Driven Design]({{ site.docs_url }}/learn/domain-driven-design).
- Tests for your APIs, the endpoints handling requests.
- Tests for your stacks, the code that creates your infrastructure.

## Launch event

We hosted a [launch livestream on YouTube](https://www.youtube.com/watch?v=YtaxDURRjHA) where we talked about how to write tests for your SST apps.

<div class="youtube-container">
  <iframe src="https://www.youtube-nocookie.com/embed/YtaxDURRjHA" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

The video is timestamped and here's roughly what we covered.

1. Intro
2. Setting up a new app
3. Testing domain code
4. Testing APIs
5. Testing stacks
6. Deep dive into `sst load-config`
7. Q&A
   1. How to test asynchronous workflow?
   2. How to run tests in parallel?

## Get started

To get started, create a new SST app with our GraphQL starter.

```bash
$ npx create-sst@latest
```

Make sure to select the `graphql` and `DynamoDB` option.

Next, install the dependencies.

```bash
$ cd my-sst-app
$ npm install
```

And you can run your tests by running:

```bash
npm test
```

Make sure to check out the sample test included with the starter to get a sense of how it all works!

To learn more [**check out our docs**]({{ site.docs_url }}/advanced/testing).
