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

First, log in to your [AWS Console](https://console.aws.amazon.com) and search for IAM in the search bar. Hover or focus on the **IAM card** and then select the **Users** link.

![Select IAM Service Screenshot](/assets/create-iam-user/search-to-iam-service.png)

Select **Add Users**.

![Add IAM User Screenshot](/assets/create-iam-user/add-iam-user-button.png)

Enter a **User name**, then select **Next**.

This account will be used by our [AWS CLI](https://aws.amazon.com/cli/) and [SST]({{ site.sst_github_repo }}). They will be connecting to the AWS API directly and will not be using the Management Console.  

{%note%} 
It is best practice to avoid creating keys when possible.  When using programmatic access keys, regularly rotate them.  In most cases, there are alternative solutions, see the [AWS IAM User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_RotateAccessKey) for more information.
{%endnote%}

![Fill in IAM User Info Screenshot](/assets/create-iam-user/fill-in-iam-user-details.png)

Select **Attach existing policies directly**.

![Add IAM User Policy Screenshot](/assets/create-iam-user/add-iam-attach-policies-directly.png)

Search for **AdministratorAccess** and select the policy by checking the checkbox, then select **Next**.  

We can provide a more fine-grained policy here. We cover this later in the [Customize the Serverless IAM Policy]({% link _chapters/customize-the-serverless-iam-policy.md %}) chapter. But for now, let's continue with this.

![Added Admin Policy Screenshot](/assets/create-iam-user/iam-user-add-admin-policy.png)

Select **Create user**.

![Reivew IAM User Screenshot](/assets/create-iam-user/iam-create-user.png)

Select **View user**.

![View IAM User Screenshot](/assets/create-iam-user/iam-success-view-user.png)

Select **Security credentials**

![IAM User Security Credentials Screenshot](/assets/create-iam-user/iam-user-security-credentials.png)

Select **Create access key**

![IAM User Create Access Key Screenshot](/assets/create-iam-user/iam-user-create-access-key.png)

In keeping with the current guide instructions, we will choose other to generate an access key and secret.  Select **Other** and select **Next**

![IAM User Access Key Purpose](/assets/create-iam-user/iam-user-access-key-purpose.png)

You could add a descriptive tag here, but we will skip that in this tutorial, select **Create access key**

![IAM User Access Key Purpose](/assets/create-iam-user/iam-access-key-skip-tag-create.png)

Select **Show** to reveal **Secret access key**.

![IAM User Access Key Show](/assets/create-iam-user/iam-access-key-secret-show.png)

{%note%}
This is the only screen on which you will be able to access this key.  Save it to a secure location using best practices to ensure the security of your application.
{%endnote%}

Take a note of the **Access key** and **Secret access key**. We will be needing this in the next chapter.

![IAM Access Credentials Screenshot](/assets/create-iam-user/iam-access-credentials.png)

Now let's configure our AWS CLI.  By configuring the AWS CLI, we can deploy our applications from our command line.
