---
layout: post
title: Create a Cognito User Pool
date: 2016-12-28 00:00:00
---

Amazon Cognito User Pool makes it easy for developers to add sign-up and sign-in functionality to web and mobile applications. It serves as your own identity provider to maintain a user directory. It supports user registration and sign-in, as well as provisioning identity tokens for signed-in users.

In this chapter, we are going to create a user pool for our React app.

### Create User Pool

First, log in to your [AWS Console](https://console.aws.amazon.com) and select Cognito from the list of services.

![Select Cognito Service screenshot]({{ site.url }}/assets/cognito-user-pool/select-cognito-service.png)

Select **Manage your User Pools**

![Select Manage Your User Pools screenshot]({{ site.url }}/assets/cognito-user-pool/select-manage-your-user-pools.png)

Select **Create a User Pool**

![Select Create a User Pool screenshot]({{ site.url }}/assets/cognito-user-pool/select-create-a-user-pool.png)

Enter **Pool name** and select **Review defaults**

![Fill in User Pool info screenshot]({{ site.url }}/assets/cognito-user-pool/fill-in-user-pool-info.png)

Select **Create pool** at the bottom of the page

![Select Create pool screenshot]({{ site.url }}/assets/cognito-user-pool/select-create-pool.png)

The user pool is created. Take a note of the **Pool Id** which will be required later in setting up **Identity Pool** and **Serverless Api**.

![User Pool Created Screenshot]({{ site.url }}/assets/cognito-user-pool/user-pool-created.png)

### Create App

Select **Apps** from the left menu

![Select User Pool Apps Screenshot]({{ site.url }}/assets/cognito-user-pool/select-user-pool-apps.png)

Select **Add an app**

![Select Add An App Screenshot]({{ site.url }}/assets/cognito-user-pool/select-add-an-app.png)

Enter **App name**, select **Enable sign-in API for server-based authentication**, then select **Create app**.

![Fill User Pool App Info Screenshot]({{ site.url }}/assets/cognito-user-pool/fill-user-pool-app-info.png)

The app is created. Take a note of the **App client id** which will be required later in setting up **Identity Pool**.

![User Pool App Created Screenshot]({{ site.url }}/assets/cognito-user-pool/user-pool-app-created.png)

### Create Test User

You could also manually add users to the user pool through the AWS console. Let's create a test user which we can use later to test the login page of our React App.

Select **Users and groups** from the left menu.

![Select User Pool Users Screenshot]({{ site.url }}/assets/cognito-user-pool/select-user-pool-useres.png)

Select **Create user**.

![Select Create User Screenshot]({{ site.url }}/assets/cognito-user-pool/select-create-user.png)

Enter a **Username** and **Temporary password** that conforms with the password policy specified when creating the user pool.

Leave the **Phone number** blank and uncheck **Mark phone number as verified?**.

Enter an **Email**. Select **Create user**.

![Fill in User Info Screenshot]({{ site.url }}/assets/cognito-user-pool/fill-in-user-info.png)

The user is created. An email should be sent to the user's email address with the username and password.

![User Pool User Created Screenshot]({{ site.url }}/assets/cognito-user-pool/user-pool-user-created.png)
