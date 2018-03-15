---
layout: post
title: Create a Cognito User Pool
date: 2016-12-28 00:00:00
description: Amazon Cognito User Pool handles sign-up and sign-in functionality for web and mobile apps. We are going to create a Cognito User Pool to store and manage the users for our serverless app. We'll use the email address as username option since we want our users to login with their email. We are also going to set up our app as an App Client for our Cognito User Pool.
context: all
comments_id: 17
---

Our notes app needs to handle user accounts and authentication in a secure and reliable way. To do this we are going to use [Amazon Cognito](https://aws.amazon.com/cognito/).

Amazon Cognito User Pool makes it easy for developers to add sign-up and sign-in functionality to web and mobile applications. It serves as your own identity provider to maintain a user directory. It supports user registration and sign-in, as well as provisioning identity tokens for signed-in users.

In this chapter, we are going to create a User Pool for our notes app.

### Create User Pool

From your [AWS Console](https://console.aws.amazon.com), select **Cognito** from the list of services.

![Select Amazon Cognito Service screenshot](/assets/cognito-user-pool/select-cognito-service.png)

Select **Manage your User Pools**.

![Select Manage Your Cognito User Pools screenshot](/assets/cognito-user-pool/select-manage-your-user-pools.png)

Select **Create a User Pool**.

![Select Create a Cognito User Pool screenshot](/assets/cognito-user-pool/select-create-a-user-pool.png)

Enter **Pool name** and select **Review defaults**.

![Fill in Cognito User Pool info screenshot](/assets/cognito-user-pool/fill-in-user-pool-info.png)

Select **Choose username attributes...**.

![Choose username attribute screenshot](/assets/cognito-user-pool/choose-username-attributes.png)

And select **Email address or phone numbers** and **Allow email addresses**. This is telling Cognito User Pool that we want our users to be able to sign up and login with their email as their username.

![Select email address as username screenshot](/assets/cognito-user-pool/select-email-address-as-username.png)

Scroll down and select **Next step**.

![Select attributes next step screenshot](/assets/cognito-user-pool/select-next-step-attributes.png)

Hit **Review** in the side panel and make sure that the **Username attributes** is set to **email**.

![Review User Pool settings screenshot](/assets/cognito-user-pool/review-user-pool-settings.png)

Now hit **Create pool** at the bottom of the page.

![Select Create pool screenshot](/assets/cognito-user-pool/select-create-pool.png)

Now that the User Pool is created. Take a note of the **Pool Id** and **Pool ARN** which will be required later. Also, note the region that your User Pool is created in. In our case it is in `us-east-1`.

![Cognito User Pool Created Screenshot](/assets/cognito-user-pool/user-pool-created.png)

### Create App Client

Select **App clients** from the left panel.

![Select Congito User Pool Apps Screenshot](/assets/cognito-user-pool/select-user-pool-apps.png)

Select **Add an app client**.

![Select Add An App Screenshot](/assets/cognito-user-pool/select-add-an-app.png)

Enter **App client name**, un-select **Generate client secret**, select **Enable sign-in API for server-based authentication**, then select **Create app client**.

- **Generate client secret**: user pool apps with a client secret are not supported by JavaScript SDK. We need to un-select the option.
- **Enable sign-in API for server-based authentication**: required by AWS CLI when managing the pool users via command line interface. We will be creating a test user through command line interface in the next chapter.

![Fill Cognito User Pool App Info Screenshot](/assets/cognito-user-pool/fill-user-pool-app-info.png)

Now that the app client is created. Take a note of the **App client id** which will be required in the later chapters.

![Cognito User Pool App Created Screenshot](/assets/cognito-user-pool/user-pool-app-created.png)


### Create Domain Name

Finally, select **Domain name** from the left panel. Enter your unique domain name and select **Save changes**. In our case we are using `notes-app`.

![Select Congito User Pool Apps Screenshot](/assets/cognito-user-pool/user-pool-domain-name.png)


Now our Cognito User Pool is ready. It will maintain a user directory for our notes app. It will also be used to authenticate access to our API. Next let's set up a test user within the pool.
