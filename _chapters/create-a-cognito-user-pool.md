---
layout: post
title: Create a Cognito User Pool
---

The user pools feature makes it easy for developers to add sign-up and sign-in functionality to web and mobile applications. It serves as your own identity provider to maintain a user directory. It supports user registration and sign-in, as well as provisioning identity tokens for signed-in users.


### Create User Pool

First, log in to your [AWS Console](https://console.aws.amazon.com) and select Cognito from the list of services.

![Select Cognito Service screenshot]({{ site.url }}/assets/cognito-user-pool/1.png)

Select **Manage your User Pools**

![Select Manage your User Pools screenshot]({{ site.url }}/assets/cognito-user-pool/2.png)

Select **Create a User Pool**

![Select Create a User Pool screenshot]({{ site.url }}/assets/cognito-user-pool/3.png)

Enter **Pool name** and select **Review defaults**

![Select Review defaults screenshot]({{ site.url }}/assets/cognito-user-pool/4.png)

Select **Create pool**

![Select Create pool screenshot]({{ site.url }}/assets/cognito-user-pool/5.png)

The user pool is created. Take a note of the **Pool Id** which will be required later in setting up **Identity Pool** and **Serverless Api**.

![Screenshot]({{ site.url }}/assets/cognito-user-pool/6.png)

### Create App

Select **Apps** from the left menu

![Screenshot]({{ site.url }}/assets/cognito-user-pool/6.png)

Select **Add an app**

![Screenshot]({{ site.url }}/assets/cognito-user-pool/7.png)

Enter **App name** and select **Create app**

![Screenshot]({{ site.url }}/assets/cognito-user-pool/8.png)

The app is created. Take a note of the **App client id** which will be required later in setting up **Identity Pool**.

![Screenshot]({{ site.url }}/assets/cognito-user-pool/9.png)
