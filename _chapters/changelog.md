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

You can get these updates emailed to you via our [newsletter]({{ site.newsletter_signup_form }}).

### Changes

#### [v2.2: Updating to user Node.js starter and v8.10](https://branchv22--serverless-stack.netlify.com) (Current)

Apr 11, 2018: Updating the backend to use Node.js starter and Lambda Node v8.10. [Discussion on the update]({{ site.github_repo }}/issues/223).

- [Tutorial changes]({{ site.github_repo }}/compare/v2.1...v2.2)
- [API]({{ site.backend_github_repo }}/compare/v2.1...v2.2)

#### [v2.1: Updating to Webpack 4](https://branchv21--serverless-stack.netlify.com)

Mar 21, 2018: Updating the backend to use Webpack 4 and serverless-webpack 5.

- [Tutorial changes]({{ site.github_repo }}/compare/v2.0...v2.1)
- [API]({{ site.backend_github_repo }}/compare/v1.2.3...v2.1)

#### [v2.0: AWS Amplify update](https://branchv20--serverless-stack.netlify.com)

Mar 15, 2018: Updating frontend to use AWS Amplify. Verifying SSL certificate now uses DNS validation. [Discussion on the update]({{ site.github_repo }}/issues/123).

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2.5...v2.0)
- [Client]({{ site.frontend_github_repo }}/compare/v1.2.5...v2.0)

#### [v1.2.5: Using specific Bootstrap CSS version](https://branchv125--serverless-stack.netlify.com)

Feb 5, 2018: Using specific Bootstrap CSS version since `latest` now points to Bootstrap v4. But React-Bootstrap uses v3.

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2.4...v1.2.5)
- [Client]({{ site.frontend_github_repo }}/compare/v1.2.4...v1.2.5)

#### [v1.2.4: Updating to React 16](https://5a4993f3a6188f5a88e0c777--serverless-stack.netlify.com/)

Dec 31, 2017: Updated to React 16 and fixed `sigv4Client.js` [IE11 issue]({{ site.github_repo }}/issues/114#issuecomment-349938586).

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2.3...v1.2.4)
- [Client]({{ site.frontend_github_repo }}/compare/v1.2...v1.2.4)

#### [v1.2.3: Updating to babel-preset-env](https://5a4993898198761218a1279f--serverless-stack.netlify.com/)

Dec 30, 2017: Updated serverless backend to use babel-preset-env plugin and added a note to the Deploy to S3 chapter on reducing React app bundle size.

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2.2...v1.2.3)
- [API]({{ site.backend_github_repo }}/compare/v1.2...v1.2.3)

#### [v1.2.2: Adding new chapters](https://5a499324a6188f5a88e0c76d--serverless-stack.netlify.com/)

Dec 1, 2017: Added the following *Extra Credit* chapters.

1. Customize the Serverless IAM Policy
2. Environments in Create React App

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2.1...v1.2.2)

#### [v1.2.1: Adding new chapters](https://5a4992e70b79b76fb0948300--serverless-stack.netlify.com/)

Oct 7, 2017: Added the following *Extra Credit* chapters.

1. API Gateway and Lambda Logs
2. Debugging Serverless API Issues
3. Serverless environment variables
4. Stages in Serverless Framework
5. Configure multiple AWS profiles

- [Tutorial changes]({{ site.github_repo }}/compare/v1.2...v1.2.1)

#### [v1.2: Upgrade to Serverless Webpack v3](https://59caac9bcf321c5b78f2c3e2--serverless-stack.netlify.com/)

Sep 16, 2017: Upgrading serverless backend to using serverless-webpack plugin v3. The new version of the plugin changes some of the commands used to test the serverless backend. [Discussion on the update]({{ site.github_repo }}/issues/130).

- [Tutorial changes]({{ site.github_repo }}/compare/v1.1...v1.2)
- [API]({{ site.backend_github_repo }}/compare/v1.1...v1.2)

#### [v1.1: Improved Session Handling](https://59caae1e6f4c50416e86701d--serverless-stack.netlify.com/)

Aug 30, 2017: Fixing some issues with session handling in the React app. A few minor updates bundled together. [Discussion on the update]({{ site.github_repo }}/issues/123).

- [Tutorial changes]({{ site.github_repo }}/compare/v1.0...v1.1)
- [Client]({{ site.frontend_github_repo }}/compare/v1.0...v1.1)

#### [v1.0: IAM as authorizer](https://59caae01424ef20727c342ce--serverless-stack.netlify.com/)

July 19, 2017: Switching to using IAM as an authorizer instead of the authenticating directly with User Pool. This was a major update to the tutorial. [Discussion on the update]({{ site.github_repo }}/issues/108).

- [Tutorial changes]({{ site.github_repo }}/compare/v0.9...v1.0)
- [API]({{ site.backend_github_repo }}/compare/v0.9...v1.0)
- [Client]({{ site.frontend_github_repo }}/compare/v0.9...v1.0)

#### [v0.9: Cognito User Pool as authorizer](https://59caadbd424ef20abdc342b4--serverless-stack.netlify.com/)

- [API]({{ site.backend_github_repo }}/releases/tag/v0.9)
- [Client]({{ site.frontend_github_repo }}/releases/tag/v0.9)
