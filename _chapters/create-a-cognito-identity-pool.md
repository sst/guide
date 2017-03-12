---
layout: post
title: Create a Cognito Identity Pool
date: 2016-12-29 00:00:00
description: Tutorial on how to create a Cognito Identity Pool with your User Pool as the authentication provider for your app.
---

Now that we have our Cognito User Pool setup to handle authentication, we can use that to secure other AWS resources. In our case we need to secure the S3 bucket we created in one of the previous chapters.

Amazon Cognito Federated Identities enables developers to create unique identities for your users and authenticate them with federated identity providers. With a federated identity, you can obtain temporary, limited-privilege AWS credentials to securely access other AWS services such as Amazon DynamoDB, Amazon S3, and Amazon API Gateway.

In this chapter, we are going to create a federated identity pool using the User Pool acting as the federated identity provider. Once users log into our notes app, we'll grant them limited access to the S3 Bucket for uploading files.

### Create Pool

From your [AWS Console](https://console.aws.amazon.com) and select **Cognito** from the list of services.

![Select Cognito Service screenshot]({{ site.url }}/assets/cognito-identity-pool/select-cognito-service.png)

Select **Manage Federated Identities**.

![Select Manage Federated Identities Screenshot]({{ site.url }}/assets/cognito-identity-pool/select-manage-federated-identities.png)

Enter an **Identity pool name**.

![Fill Identity Pool Info Screenshot]({{ site.url }}/assets/cognito-identity-pool/fill-identity-pool-info.png)

Select **Authentication providers**. Under **Cognito** tab, enter **User Pool ID** and **App Client ID** of the User Pool created in the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter. Select **Create Pool**.

![Fill Authentication Provider Info Screenshot]({{ site.url }}/assets/cognito-identity-pool/fill-authentication-provider-info.png)

Now we need to specify what AWS resources are accessible for users with temporary credentials obtained from the identity pool.

Select **View Details**. Two **Role Summary** sections are expanded. The top section summarizes the permission policy for authenticated users, and the bottom section summarizes that for unauthenticated users.

Select **View Policy Document** in the top section. Then select **Edit**.

![Select Edit Policy Document Screenshot]({{ site.url }}/assets/cognito-identity-pool/select-edit-policy-document.png)

It will warn you to read the documentation. Select **Ok** to edit.

![Select Confirm Edit Policy Screenshot]({{ site.url }}/assets/cognito-identity-pool/select-confirm-edit-policy.png)

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following policy into the editor. Replace `YOUR_S3_UPLOADS_BUCKET_NAME` with the **bucket name** from the [Create an S3 bucket for file uploads]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) chapter.

``` json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::YOUR_S3_UPLOADS_BUCKET_NAME/${cognito-identity.amazonaws.com:sub}*"
      ]
    }
  ]
}
```

Note **cognito-identity.amazonaws.com:sub** is the authenticated user's federated identity ID. This policy grants the authenticated user access to files with filenames prefixed by the user's id in the S3 bucket as a security measure.

Select **Allow**.

![Submit Identity Pool Policy Screenshot]({{ site.url }}/assets/cognito-identity-pool/submit-identity-pool-policy.png)

Our Identity Pool should now be created. Let's find out the Identity Pool ID.

Select **Dashboard** from the left panel, then select **Edit identity pool**.

![Identity Pool Created Screenshot]({{ site.url }}/assets/cognito-identity-pool/identity-pool-created.png)

Take a note of the **Identity pool ID** which will be required in the later chapters.

![Identity Pool Created Screenshot]({{ site.url }}/assets/cognito-identity-pool/identity-pool-id.png)

Next we'll setup the Serverless Framework to create our backend APIs.
