---
layout: post
title: Create and manage AWS accounts using AWS Organizations
description: 
date: 2019-09-30 00:00:00
comments_id: 
---

With AWS Organizations, you can create and manage all the AWS accounts in your root account. In this chapter we'll look at how to create multiple AWS accounts for the environments in our serverless app.

### Create AWS accounts

Go to the AWS Organizations console.

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-1.png)

The account labeled with the star is your **root** AWS account. This account cannot be removed from the organization.

Select **Add account**.

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-2.png)

You can either create a new AWS account or if you already have multiple standalone AWS accounts, you can add them into your organization.

Select **Create account**.

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-3.png)

Let's create our Production account first. Fill out the following:

- **Full name**: Enter Prod, Production or what you would like to call this account. It is used for display purposes only.
- **Email**: Each account requires a unique email address. Emails with the '+' sign are allowed.
- **IAM role name**: Leave this empty. When creating a new account, AWS Organizations automatically creates an IAM role in the new account that allows the root account to be able to assume into it. Actually, it's the only way to access a newly created account. By default, the IAM role is named **OrganizationAccountAccessRole**, you can give it another name.

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-4.png)

Now, you have 2 AWS accounts in your organization.

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-5.png)

### Access AWS accounts

Next, let's try switch into the Production account. First, take a note of the newly created **Account ID**. We need this number in the next step.

Then, select the account picker at the top.

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-6.png)

Select **Switch Role**.

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-7.png)

Fill in the following:

- **Account**: Account ID of the newly created Prod account from the previous step.
- **Role**: Name of the IAM role from the previous step. If you left it blank, use **OrganizationAccountAccessRole**.
- **Display Name**: It's good to use the name (Full name) from when we created the account. It'll help keep things recognizable.
- **Color**: Pick a color that represents **Production** for you.

Note that the Display Name and Color fields are personal to you. Your team members will need to set this up again on their own.

Then select **Switch Role**.

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-8.png)

Now, you are in the **Prod** account. You can check which account you are currently assumed into by looking at the top bar.

You can switch back to the root account by clicking on the account picker and selecting **Back to root** .

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-9.png)

Next, repeat the above steps to create the Development account and optionally the Staging account.

![](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations-10.png)

Now we have our AWS accounts created. Let's make sure we are using these environments correctly in the configuration of our app.
