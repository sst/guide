---
layout: post
title: Who Is This Guide For?
date: 2016-12-21 00:00:00
lang: en
ref: who-is-this-guide-for
comments_id: who-is-this-guide-for/96
---

This guide is meant for full-stack developers or developers that would like to build full stack serverless applications. By providing a step-by-step guide for both the frontend and the backend we hope that it addresses all the different aspects of building serverless applications. There are quite a few other tutorials on the web but we think it would be useful to have a single point of reference for the entire process. This guide is meant to serve as a resource for learning about how to build and deploy serverless applications, as opposed to laying out the best possible way of doing so.

So you might be a backend developer who would like to learn more about the frontend portion of building serverless apps or a frontend developer that would like to learn more about the backend; this guide should have you covered.

On a personal note, the serverless approach has been a giant revelation for us and we wanted to create a resource where we could share what we've learned. You can read more about us [**here**]({{ site.sst_url }}). And [check out a sample of what folks have built with SST]({% link showcase.md %}).

We are also catering this solely towards JavaScript/TypeScript developers for now. We might target other languages and environments in the future. But we think this is a good starting point because it can be really beneficial as a full-stack developer to use a single language (TypeScript) and environment (Node.js) to build your entire application.

### Why TypeScript

We use TypeScript across the board for this guide from the frontend, to the backend, all the way to creating our infrastructure. If you are not familiar with TypeScript you might be wondering why does typesafety matter.

One big advantage is that of using a fully typesafe setup is that your code editor can autocomplete and point out any invalid options in your code. This is really useful when you are first starting out. But it's also useful when you are working with configuring infrastructure through code.

Aside from all the autocomplete goodness, typesafety ends up being critical for the maintainability of codebases. This matters if you are planning to work with the same codebase for years to come.

It should be easy for your team to come in and make changes to parts of your codebase that have not been worked on for a long time. TypeScript allows you to do this! Your codebase no longer feels _brittle_ and you are not afraid to make changes.

#### TypeScript made easy

If you are not used to TypeScript, you might be wondering, _"Don't I have to write all these extra types for things?"_ or _"Doesn't TypeScript make my code really verbose and scary?"_.

These are valid concerns. But it turns out, if the libraries you are using are designed well for TypeScript, you won't need a lot of extra type definitions in your code. In fact, as you'll see in this tutorial, you'll get all the benefits of a fully typesafe codebase with code that looks almost like regular JavaScript.

Also, TypeScript can be gradually adopted. Meaning that you can use our TypeScript starter while adding JavaScript files to it. We don't recommend doing this, but that's always an option for you.

Let's start by looking at what we'll be covering.
