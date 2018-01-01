---
layout: post
title: Changelog
redirect_from: /chapters/older-versions.html
date: 2017-02-17 00:00:00
description: A list of all the updates made to Serverless Stack
comments_id: 124
---

As we continue to update Serverless Stack, we want to make sure that we give you a clear idea of all the changes that are being made. This is to ensure that you won't have to go through the entire tutorial again to get caught up on the updates. We also want to leave the older versions up in case you need a reference. This is also useful for readers who are working through the tutorial while it gets updated.

Below are the updates we’ve made to Serverless Stack, each with:

- Each update has a link to an **archived version of the tutorial**
- Updates to the tutorial **compared to the last version**
- Updates to the **API and Client repos**

While the hosted version of the tutorial and the code snippets are accurate, the sample project repo that is linked at the bottom of each chapter is unfortunately not. We do however maintain the past versions of the completed sample project repo. So you should be able to use those to figure things out. All this info is also available on the [releases page]({{ site.github_repo }}/releases) of our [GitHub repo]({{ site.github_repo }}).

You can get these updates emailed to you via our [newsletter]({{ site.mailchimp_signup_form }}).

### Changes

#### [v1.2.4: Updating to React 16](https://5a4993f3a6188f5a88e0c777--serverless-stack.netlify.com/) (Current)

Dec 31, 2017: Updated to React 16 and fixed `sigv4Client.js` IE11 issue.

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2.3...v1.2.4)
- [Client]({{ site.frontend_github_repo }}/compare/v1.2...v1.2.4)

#### [v1.2.3: Updating to babel-preset-env](https://5a4993898198761218a1279f--serverless-stack.netlify.com/)

Dec 30, 2017: Updated serverless backend to use babel-preset-env and added a note on reducing React app bundle size.

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2.2...v1.2.3)
- [API]({{ site.backend_github_repo }}/compare/v1.2...v1.2.3)

#### [v1.2.2: Adding new chapters](https://5a499324a6188f5a88e0c76d--serverless-stack.netlify.com/)

Dec 1, 2017: Added new chapters on environments in Create React App and customizing IAM policies for serverless.

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2.1...v1.2.2)

#### [v1.2.1: Adding new chapters](https://5a4992e70b79b76fb0948300--serverless-stack.netlify.com/)

Oct 7, 2017: Added new chapters on environment variables and stages in Serverless Framework, working with multiple AWS profiles and CloudWatch logs, and debugging Lambda issues.

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2...v1.2.1)

#### [v1.2: Upgrade to Serverless Webpack v3](https://59caac9bcf321c5b78f2c3e2--serverless-stack.netlify.com/)

Sep 16, 2017: Upgrading serverless backend to using serverless-webpack plugin v3

- [Tutorial changes]({{ site.github_repo }}/compare/v1.1...v1.2)
- [API]({{ site.backend_github_repo }}/compare/v1.1...v1.2)

#### [v1.1: Improved Session Handling](https://59caae1e6f4c50416e86701d--serverless-stack.netlify.com/)

Aug 30, 2017: Fixing some issues with session handling in the React app.

- [Tutorial changes]({{ site.github_repo }}/compare/v1.0...v1.1)
- [Client]({{ site.frontend_github_repo }}/compare/v1.0...v1.1)

#### [v1.0: IAM as authorizer](https://59caae01424ef20727c342ce--serverless-stack.netlify.com/)

July 19, 2017: Switching to using IAM as an authorizer instead of the authenticating directly with User Pool.

- [Tutorial changes]({{ site.github_repo }}/compare/v0.9...v1.0)
- [API]({{ site.backend_github_repo }}/compare/v0.9...v1.0)
- [Client]({{ site.frontend_github_repo }}/compare/v0.9...v1.0)

#### [v0.9: Cognito User Pool as authorizer](https://59caadbd424ef20abdc342b4--serverless-stack.netlify.com/)

- [API]({{ site.backend_github_repo }}/releases/tag/v0.9)
- [Client]({{ site.frontend_github_repo }}/releases/tag/v0.9)
