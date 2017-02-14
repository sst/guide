---
layout: post
title: Create an IAM User
---

An IAM User is required to access AWS service outside of AWS web console, and by Serverless Framework in a later tutorial.


### Create Pool

First, log in to your [AWS Console](https://console.aws.amazon.com) and select IAM from the list of services.

![Screenshot]({{ site.url }}/assets/iam-user/1.png)

Select **Users**

![Screenshot]({{ site.url }}/assets/iam-user/2.png)

Select **Add User**

![Screenshot]({{ site.url }}/assets/iam-user/3.png)

Enter a **User name** and check **Programmatic access**

Select **Next: Permissions**

![Screenshot]({{ site.url }}/assets/iam-user/4.png)

Select **Attach existing policies directly**.

![Screenshot]({{ site.url }}/assets/iam-user/5.png)

Search for **AdministratorAccess** and select the policy.

Select **Next: Review**

![Screenshot]({{ site.url }}/assets/iam-user/6.png)

Select **Create user**

![Screenshot]({{ site.url }}/assets/iam-user/7.png)

Select **Show** to reveal **Secret access key**. Take a note of the **Access key ID** and **Secret access key** which will be required later in setting up **Serverless Api**.

![Screenshot]({{ site.url }}/assets/iam-user/8.png)
