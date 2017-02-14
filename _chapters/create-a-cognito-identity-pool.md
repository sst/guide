---
layout: post
title: Create a Cognito Identity Pool
---

The identity pool feature allows users to obtain temporary credentials to access AWS resources such as S3,.


### Create Pool

First, log in to your [AWS Console](https://console.aws.amazon.com) and select Cognito from the list of services.

![Screenshot]({{ site.url }}/assets/cognito-user-pool/1.png)

Select **Manage Federated Identities**

![Screenshot]({{ site.url }}/assets/cognito-user-pool/2.png)

Enter **Identity pool name**

![Screenshot]({{ site.url }}/assets/cognito-user-pool/3.png)

Select **Authentication providers**. Enter **User Pool ID** and **App Client ID** of the user pool created in the earlier chapter.

Select **Create Pool**

![Screenshot]({{ site.url }}/assets/cognito-user-pool/4.png)

Select **Allow**

![Screenshot]({{ site.url }}/assets/cognito-user-pool/5.png)
