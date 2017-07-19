---
layout: post
title: Create a Cognito Identity Pool
date: 2017-01-05 00:00:00
description: Amazon Cognito Federated Identities helps us secure our AWS resources. We can use the Cognito User Pool as an identity provider for our serverless backend. To allow users to be able to upload files to our S3 bucket and connect to API Gateway we need to create an Identity Pool. We will assign it an IAM Policy with the name of our S3 bucket and prefix our files with the cognito-identity.amazonaws.com:sub. And we’ll add our API Gateway endpoint as a resource as well.
context: all
comments_id: 19
---

Now that we have deployed our backend API; we almost have all the pieces we need for our backend. We have the User Pool that is going to store all of our users and help sign in and sign them up. We also have an S3 bucket that we will use to help our users upload files as attachments for their notes. The final piece is that is one that ties all these services together in a secure way. It is called Amazon Cognito Federated Identities.

Amazon Cognito Federated Identities enables developers to create unique identities for your users and authenticate them with federated identity providers. With a federated identity, you can obtain temporary, limited-privilege AWS credentials to securely access other AWS services such as Amazon DynamoDB, Amazon S3, and Amazon API Gateway.

In this chapter, we are going to create a federated Cognito Identity Pool. We will be using our User Pool as the identity provider. We could also use Facebook, Google, or our own custom identity provider. Once a user is authenticated via our User Pool, the Identity Pool will attach an IAM Role to the user. We will define a policy for this IAM Role to grant access to the S3 bucket and our API. This is the Amazon way of securing your resources.

Let's get started.

### Create Pool

From your [AWS Console](https://console.aws.amazon.com) and select **Cognito** from the list of services.

![Select Cognito Service screenshot]({{ site.url }}/assets/cognito-identity-pool/select-cognito-service.png)

Select **Manage Federated Identities**.

![Select Manage Federated Identities Screenshot]({{ site.url }}/assets/cognito-identity-pool/select-manage-federated-identities.png)

Enter an **Identity pool name**.

![Fill Cognito Identity Pool Info Screenshot]({{ site.url }}/assets/cognito-identity-pool/fill-identity-pool-info.png)

Select **Authentication providers**. Under **Cognito** tab, enter **User Pool ID** and **App Client ID** of the User Pool created in the [Create a Cognito user pool]({% link _chapters/create-a-cognito-user-pool.md %}) chapter. Select **Create Pool**.

![Fill Authentication Provider Info Screenshot]({{ site.url }}/assets/cognito-identity-pool/fill-authentication-provider-info.png)

Now we need to specify what AWS resources are accessible for users with temporary credentials obtained from the Cognito Identity Pool.

Select **View Details**. Two **Role Summary** sections are expanded. The top section summarizes the permission policy for authenticated users, and the bottom section summarizes that for unauthenticated users.

Select **View Policy Document** in the top section. Then select **Edit**.

![Select Edit Policy Document Screenshot]({{ site.url }}/assets/cognito-identity-pool/select-edit-policy-document.png)

It will warn you to read the documentation. Select **Ok** to edit.

![Select Confirm Edit Policy Screenshot]({{ site.url }}/assets/cognito-identity-pool/select-confirm-edit-policy.png)

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following policy into the editor. Replace `YOUR_S3_UPLOADS_BUCKET_NAME` with the **bucket name** from the [Create an S3 bucket for file uploads]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) chapter. And replace the `YOUR_API_GATEWAY_REGION` and `YOUR_API_GATEWAY_ID` with the ones that you get after you deployed your API in the last chapter.

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
    },
    {
      "Effect": "Allow",
      "Action": [
        "execute-api:Invoke"
      ],
      "Resource": [
        "arn:aws:execute-api:YOUR_API_GATEWAY_REGION:*:YOUR_API_GATEWAY_ID/*"
      ]
    }
  ]
}
```

Note **cognito-identity.amazonaws.com:sub** is the authenticated user's federated identity ID. This policy grants the authenticated user access to files with filenames prefixed by the user's id in the S3 bucket as a security measure.

So effectively we are telling AWS that an authenticated user has access to two resources.

1. Files in our S3 bucket that are prefixed with their federated identity id
2. And, the APIs we deployed using API Gateway

One other thing to note is that the federated identity id is a UUID that is assigned by our Identity Pool. This is the id (`event.requestContext.identity.cognitoIdentityId`) that we were using as our user id back when we were creating our APIs.

Select **Allow**.

![Submit Cognito Identity Pool Policy Screenshot]({{ site.url }}/assets/cognito-identity-pool/submit-identity-pool-policy.png)

Our Cognito Identity Pool should now be created. Let's find out the Identity Pool ID.

Select **Dashboard** from the left panel, then select **Edit identity pool**.

![Cognito Identity Pool Created Screenshot]({{ site.url }}/assets/cognito-identity-pool/identity-pool-created.png)

Take a note of the **Identity pool ID** which will be required in the later chapters.

![Cognito Identity Pool Created Screenshot]({{ site.url }}/assets/cognito-identity-pool/identity-pool-id.png)

Now before we test our serverless API let's take a quick look at the Cognito User Pool and Cognito Identity Pool and make sure we've got a good idea of the two concepts and the differences between them.
