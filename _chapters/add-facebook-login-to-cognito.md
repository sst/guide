---
layout: post
title: Add Facebook Login to Cognito
description:
date: 2018-04-11 00:00:00
context: true
comments_id:
---

https://github.com/AnomalyInnovations/serverless-stack-demo-client/pull/26

# Create a Facebook App

1. Create a new app http://developers.facebook.com/

2. Choose Facebook login and select Web

3. Select the URL for your app `http://localhost:3000`

4. Under Facebook login settings add your OAuth redirect URL `https://${user-pool-domain-name}.auth.${region}.amazoncognito.com/oauth2/idpresponse`

5. Go to Settings > Basic and get your app id and app secret

# Cognito User Pool

1. Add domain to Cognito User Pool

2. Select Facebook in Identity Providers

3. Add your Facebook app ID and App Secret and scopes

4. Map your Facebook attributes

# Cognito Identity Pool

1. Select Facebook as an Authentication Provider

2. Add your Facebook app id

# React

1. Add Facebook App id to config

2. Install `react-facebook-sdk`

3. Add `FacebookButton.js`
