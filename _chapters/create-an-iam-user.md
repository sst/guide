---
layout: post
title: Create an IAM User
---

Amazon IAM (Identity and Access Management) enables AWS customers to manage users and user permissions in AWS. You can create one or more IAM users in your AWS account. You might create an IAM user for someone who needs access to your AWS console, or when you have a new application that needs to make API calls to AWS.

In this chapter, we are going to create a new IAM user for Serverless Framework, who will be managing our Amazon Lambda, Amazon Api Gate and other Amazon services for us.

### Create User

First, log in to your [AWS Console](https://console.aws.amazon.com) and select IAM from the list of services.

![Select IAM Service Screenshot]({{ site.url }}/assets/iam-user/select-iam-service.png)

Select **Users**

![Select IAM Users Screenshot]({{ site.url }}/assets/iam-user/select-iam-users.png)

Select **Add User**

![Add IAM User Screenshot]({{ site.url }}/assets/iam-user/add-iam-user.png)

Enter a **User name** and check **Programmatic access**, then select **Next: Permissions**

Serverless Framework will manage our services through AWS API. It does not need access to our AWS Management Console.

![Fill in IAM User Info Screenshot]({{ site.url }}/assets/iam-user/fill-in-iam-user-info.png)

Select **Attach existing policies directly**.

![Add IAM User Policy Screenshot]({{ site.url }}/assets/iam-user/add-iam-user-policy.png)

Search for **AdministratorAccess** and select the policy, then select **Next: Review**

![Added Admin Policy Screenshot]({{ site.url }}/assets/iam-user/added-admin-policy.png)

Select **Create user**

![Reivew IAM User Screenshot]({{ site.url }}/assets/iam-user/review-iam-user.png)

Select **Show** to reveal **Secret access key**.

![Added IAM User Screenshot]({{ site.url }}/assets/iam-user/added-iam-user.png)

Take a note of the **Access key ID** and **Secret access key**.

![IAM User Credentials Screenshot]({{ site.url }}/assets/iam-user/iam-user-credentials.png)

Next we'll be using this info to configure the AWS CLI.
