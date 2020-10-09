---
layout: post
title: Manage AWS Accounts Using AWS Organizations
description: In this chapter we look at how to create multiple AWS accounts for the environments in your Serverless Framework app. We'll be using the AWS Organizations console for this.
date: 2019-09-30 00:00:00
comments_id: manage-aws-accounts-using-aws-organizations/1326
---

With AWS Organizations, you can create and manage all the AWS accounts in your master account. In this chapter we'll look at how to create multiple AWS accounts for the environments in our serverless app.

### Create AWS accounts

Go to the AWS Organizations console.

![Select AWS Organizations service](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/select-aws-organizations-service.png)

The account labeled with the star is your **master** AWS account. This account cannot be removed from the organization.

Select **Add account**.

![Add account in AWS Organizations](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/add-account-in-aws-organizations.png)

You can either create a new AWS account or if you already have multiple standalone AWS accounts, you can add them into your organization.

Select **Create account**.

![Create account in AWS Organizations](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/create-account-in-aws-organizations.png)

Let's create our Production account first. Fill out the following:

- **Full name**: Enter Prod, Production or what you would like to call this account. It is used for display purposes only.
- **Email**: Each account requires a unique email address. Emails with the '+' sign are allowed.
- **IAM role name**: Leave this empty. When creating a new account, AWS Organizations automatically creates an IAM role in the new account that allows the master account to be able to assume into it. Actually, it's the only way to access a newly created account. By default, the IAM role is named **OrganizationAccountAccessRole**, you can give it another name.

![Set Production account detail](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/set-production-account-detail.png)

Now, you have 2 AWS accounts in your organization.

![Production account created in AWS Organizations](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/production-account-created-in-aws-organizations.png)

### Access AWS accounts

Next, let's try switch into the Production account. First, take a note of the newly created **Account ID**. We need this number in the next step.

Then, select the account picker at the top.

![Select account picker in AWS console](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/select-account-picker-in-aws-console.png)

Select **Switch Role**.

![Select switch role in AWS console](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/select-switch-role-in-aws-console.png)

Fill in the following:

- **Account**: Account ID of the newly created Prod account from the previous step.
- **Role**: Name of the IAM role from the previous step. If you left it blank, use **OrganizationAccountAccessRole**.
- **Display Name**: It's good to use the name (Full name) from when we created the account. It'll help keep things recognizable.
- **Color**: Pick a color that represents **Production** for you.

Note that the Display Name and Color fields are personal to you. Your team members will need to set this up again on their own.

Then select **Switch Role**.

![Assume role in Production account](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/assume-role-in-production-account.png)

Now, you are in the **Prod** account. You can check which account you are currently assumed into by looking at the top bar.

You can switch back to the master account by clicking on the account picker and selecting **Back to master** .

![Switch back to master account](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/switch-back-to-master-account.png)

Next, repeat the above steps to create the Development account.

![Create Development account in AWS Organizations](/assets/best-practices/create-and-manage-aws-accounts-using-aws-organizations/create-development-account-in-aws-organizations.png)

Now we have our AWS accounts created. Let's make sure we are using these environments correctly in the configuration of our app.
