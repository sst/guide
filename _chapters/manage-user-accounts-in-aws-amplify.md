---
layout: post
title: Manage User Accounts in AWS Amplify
description: In the next series of chapters we will look at how to manage user accounts for our Serverless React app with Cognito and AWS Amplify.
date: 2018-04-13 00:00:00
context: true
code: user-management
comments_id: manage-user-accounts-in-aws-amplify/505
---

If you've followed along with [Part I of the Serverless Stack](/#part-1) guide, you might be looking to add ways your users can better manage their accounts. This includes the ability to:

- Reset their password in case they forget it
- Change their password once they are logged in
- And change the email they are logging in with

As a quick refresher, we are using [AWS Cognito](https://aws.amazon.com/cognito/) as our authentication and user management provider. And on the frontend we are using [AWS Amplify](https://aws-amplify.github.io/) with our [Create React App](https://github.com/facebook/create-react-app).

In the next few chapters we are going to look at how to add the above functionality to our [Serverless notes app](https://demo.serverless-stack.com). For these chapters we are going to use a forked version of the notes app. You can [view the hosted version here](https://demo-user-mgmt.serverless-stack.com) and the [source is available in a repo here]({{ site.frontend_user_mgmt_github_repo }}).

Let's get started by allowing users to reset their password in case they have forgotten it.
