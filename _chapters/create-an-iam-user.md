---
layout: post
title: Create an IAM User
date: 2016-12-25 12:00:00
description: Tutorial on how to create an IAM user for your AWS account.
---

Amazon IAM (Identity and Access Management) enables you to manage users and user permissions in AWS. You can create one or more IAM users in your AWS account. You might create an IAM user for someone who needs access to your AWS console, or when you have a new application that needs to make API calls to AWS. This is to add an extra layer of security to your AWS account.

In this chapter, we are going to create a new IAM user for a couple of the AWS related tools we are going to be using later.

### Create User

First, log in to your [AWS Console](https://console.aws.amazon.com) and select IAM from the list of services.

![Select IAM Service Screenshot]({{ site.url }}/assets/iam-user/select-iam-service.png)

Select **Users**.

![Select IAM Users Screenshot]({{ site.url }}/assets/iam-user/select-iam-users.png)

Select **Add User**.

![Add IAM User Screenshot]({{ site.url }}/assets/iam-user/add-iam-user.png)

Enter a **User name** and check **Programmatic access**, then select **Next: Permissions**.

This account will be used by our [AWS CLI](https://aws.amazon.com/cli/) and [Serverless Framework](https://serverless.com). They'll be connecting to the AWS API directly and will not be using the Management Console.

![Fill in IAM User Info Screenshot]({{ site.url }}/assets/iam-user/fill-in-iam-user-info.png)

Select **Attach existing policies directly**.

![Add IAM User Policy Screenshot]({{ site.url }}/assets/iam-user/add-iam-user-policy.png)

Search for **AdministratorAccess** and select the policy, then select **Next: Review**.

We can provide a more finely grained policy but this will do for now.

![Added Admin Policy Screenshot]({{ site.url }}/assets/iam-user/added-admin-policy.png)

Select **Create user**.

![Reivew IAM User Screenshot]({{ site.url }}/assets/iam-user/review-iam-user.png)

Select **Show** to reveal **Secret access key**.

![Added IAM User Screenshot]({{ site.url }}/assets/iam-user/added-iam-user.png)

Take a note of the **Access key ID** and **Secret access key**. We will be needing this later.

![IAM User Credentials Screenshot]({{ site.url }}/assets/iam-user/iam-user-credentials.png)

Next we'll be using this info to configure the AWS CLI.
