---
layout: post
title: Create a Cognito User Pool
date: 2016-12-28 00:00:00
---

Our notes app needs to handle user accounts and authentication in a secure and reliable way. To do this we are going to use [Amazon Cognito](https://aws.amazon.com/cognito/).

Amazon Cognito User Pool makes it easy for developers to add sign-up and sign-in functionality to web and mobile applications. It serves as your own identity provider to maintain a user directory. It supports user registration and sign-in, as well as provisioning identity tokens for signed-in users.

In this chapter, we are going to create a User Pool for our notes app.

### Create User Pool

From your [AWS Console](https://console.aws.amazon.com), select **Cognito** from the list of services.

![Select Cognito Service screenshot]({{ site.url }}/assets/cognito-user-pool/select-cognito-service.png)

Select **Manage your User Pools**.

![Select Manage Your User Pools screenshot]({{ site.url }}/assets/cognito-user-pool/select-manage-your-user-pools.png)

Select **Create a User Pool**.

![Select Create a User Pool screenshot]({{ site.url }}/assets/cognito-user-pool/select-create-a-user-pool.png)

Enter **Pool name** and select **Review defaults**.

![Fill in User Pool info screenshot]({{ site.url }}/assets/cognito-user-pool/fill-in-user-pool-info.png)

Select **Create pool** at the bottom of the page.

![Select Create pool screenshot]({{ site.url }}/assets/cognito-user-pool/select-create-pool.png)

Now that the User Pool is created. Take a note of the **Pool Id** and **Pool ARN** which will be required later.

![User Pool Created Screenshot]({{ site.url }}/assets/cognito-user-pool/user-pool-created.png)

### Create App

Select **Apps** from the left panel.

![Select User Pool Apps Screenshot]({{ site.url }}/assets/cognito-user-pool/select-user-pool-apps.png)

Select **Add an app**.

![Select Add An App Screenshot]({{ site.url }}/assets/cognito-user-pool/select-add-an-app.png)

Enter **App name**, select **Enable sign-in API for server-based authentication**, then select **Create app**.

![Fill User Pool App Info Screenshot]({{ site.url }}/assets/cognito-user-pool/fill-user-pool-app-info.png)

Now that the app is created. Take a note of the **App client id** which will be required in the later chapters.

![User Pool App Created Screenshot]({{ site.url }}/assets/cognito-user-pool/user-pool-app-created.png)

### Create a Test User

You can manually add users to the User Pool through the AWS console. Let's create a test user which we can use later to test parts of our app as we are developing it.

Select **Users and groups** from the left menu.

![Select User Pool Users Screenshot]({{ site.url }}/assets/cognito-user-pool/select-user-pool-useres.png)

Select **Create user**.

![Select Create User Screenshot]({{ site.url }}/assets/cognito-user-pool/select-create-user.png)

Enter a **Username** and **Temporary password** that conforms with the password policy specified when creating the User Pool.

Leave the **Phone number** blank and uncheck the **Mark phone number as verified?** field.

Enter an **Email** and select **Create user**.

![Fill in User Info Screenshot]({{ site.url }}/assets/cognito-user-pool/fill-in-user-info.png)

An email should be sent to the user's email address with the username and password.

![User Pool User Created Screenshot]({{ site.url }}/assets/cognito-user-pool/user-pool-user-created.png)

Next let's setup Cognito Identity Pools to secure the S3 Bucket we created for file uploads.
