---
layout: post
title: Building a CDK app with SST
date: 2020-09-18 00:00:00
lang: en
description: 
ref: building-a-cdk-app-with-sst
comments_id: 
---

We are going to be using AWS CDK to create and deploy the infrastructure our Serverless app is going to need. We are using Serverless Framework for our APIs and to use CDK withit, we'll be using the [**Serverless Stack Toolkit**](https://github.com/serverless-stack/serverless-stack) (SST). It's an extension of CDK that allows us to deploy it alongside our Serverless Framework service.

Let's get started.


Now, let's start by configuring our infrastructure. We'll look at DynamoDB first.
