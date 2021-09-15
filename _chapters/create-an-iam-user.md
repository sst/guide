---
layout: post
title: Create an IAM User
date: 2016-12-25 12:00:00
lang: en
ref: create-an-iam-user
description: To interact with AWS using some command line tools we need to create an IAM user through the AWS console.
comments_id: create-an-iam-user/92
---

Once we have an AWS account, we'll need to create an IAM user to programmatically interact with it. We'll be using this later to configure our AWS CLI (command-line interface).

Amazon IAM (Identity and Access Management) enables you to manage users and user permissions in AWS. You can create one or more IAM users in your AWS account. You might create an IAM user for someone who needs access to your AWS console, or when you have a new application that needs to make API calls to AWS. This is to add an extra layer of security to your AWS account.

In this chapter, we are going to create a new IAM user for a couple of the AWS related tools we are going to be using later.

### Create User

First, log in to your [AWS Console](https://console.aws.amazon.com) and select IAM from the list of services.

![Select IAM Service Screenshot](/assets/iam-user/select-iam-service.png)

Select **Users**.

![Select IAM Users Screenshot](/assets/iam-user/select-iam-users.png)

Select **Add User**.

![Add IAM User Screenshot](/assets/iam-user/add-iam-user.png)

Enter a **User name** and check **Programmatic access**, then select **Next: Permissions**.

This account will be used by our [AWS CLI](https://aws.amazon.com/cli/) and [Serverless Stack Framework (SST)]({{ site.sst_github_repo }}). They'll be connecting to the AWS API directly and will not be using the Management Console.

![Fill in IAM User Info Screenshot](/assets/iam-user/fill-in-iam-user-info.png)

Select **Attach existing policies directly**.

![Add IAM User Policy Screenshot](/assets/iam-user/add-iam-user-policy.png)

Search for **AdministratorAccess** and select the policy, then select **Next: Tags**.

We can provide a more fine-grained policy here and we cover this later in the [Customize the Serverless IAM Policy]({% link _chapters/customize-the-serverless-iam-policy.md %}) chapter. But for now, let's continue with this.

![Added Admin Policy Screenshot](/assets/iam-user/added-admin-policy.png)

We can optionally add some info to our IAM user. But we'll skip this for now. Click **Next: Review**.

![Skip IAM tags Screenshot](/assets/iam-user/skip-iam-tags.png)

Select **Create user**.

![Reivew IAM User Screenshot](/assets/iam-user/review-iam-user.png)

Select **Show** to reveal **Secret access key**.

![Added IAM User Screenshot](/assets/iam-user/added-iam-user.png)

Take a note of the **Access key ID** and **Secret access key**. We will be needing this in the next chapter.

![IAM User Credentials Screenshot](/assets/iam-user/iam-user-credentials.png)

Now let's configure our AWS CLI so we can deploy our applications from our command line.
