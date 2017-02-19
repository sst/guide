---
layout: post
title: Create a Cognito Identity Pool
---

Amazon Cognito Federated Identities enable developer to create unique identities for your users and authenticate them with federated identity providers. With a federated identity, you can obtain temporary, limited-privilege AWS credentials to securely access other AWS services such as Amazon DynamoDB, Amazon S3, and Amazon API Gateway. Amazon Cognito Federated Identities support federated identity providers — including Amazon, Facebook, Google, Twitter, OpenID Connect providers, and SAML identity providers — as well as unauthenticated identities.

In this chapter, we are going to create a federated identity pool using the user pool we created in the previous chapter acting as the federated identity provider. Once users log into our React App, we will grant them limited access to the Amazon S3 bucket we created in a previous chapter for user file upload.

### Create Pool

First, log in to your [AWS Console](https://console.aws.amazon.com) and select Cognito from the list of services.

![Select Cognito Service screenshot]({{ site.url }}/assets/cognito-identity-pool/select-cognito-service.png)

Select **Manage Federated Identities**

![Select Manage Federated Identities Screenshot]({{ site.url }}/assets/cognito-identity-pool/select-manage-federated-identities.png)

Enter **Identity pool name**

![Fill Identity Pool Info Screenshot]({{ site.url }}/assets/cognito-identity-pool/fill-identity-pool-info.png)

Select **Authentication providers**. Under **Cognito** tab, enter **User Pool ID** and **App Client ID** of the user pool created in the earlier chapter. Select **Create Pool**.

![Fill Authentication Provider Info Screenshot]({{ site.url }}/assets/cognito-identity-pool/fill-authentication-provider-info.png)

Now we need to specify what AWS resources are accessible for users with temporary credentials obtained from the identity pool.

Select **View Details**. Two **Role Summary** sections are expanded. The top section summarizes the permission policy for authenticated users, and the bottom section summarizes that for unauthenticated users.

Select **View Policy Document** in the top section. Then select **Edit**.

![Select Edit Policy Document Screenshot]({{ site.url }}/assets/cognito-identity-pool/select-edit-policy-document.png)

It will warn you to read the documentation. Select **Ok** to edit.

![Select Confirm Edit Policy Screenshot]({{ site.url }}/assets/cognito-identity-pool/select-confirm-edit-policy.png)

Add the following polity into the editor.

Note the line **arn:aws:s3:::anomaly-notes-app/${cognito-identity.amazonaws.com:sub}***, where **react-notes-app** is the name of our S3 bucket, and **cognito-identity.amazonaws.com:sub** is the authenticated user's federated identity ID. This policy grants the authencated user access to files with filename prefixed by the user's ID in the S3 bucket as a security measure.

{% highlight json %}
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
        "arn:aws:s3:::react-notes-app/${cognito-identity.amazonaws.com:sub}*"
      ]
    }
  ]
}
{% endhighlight %}

Select **Allow**

![Submit Identity Pool Policy Screenshot]({{ site.url }}/assets/cognito-identity-pool/submit-identity-pool-policy.png)

The identity pool is created.

![Identity Pool Created Screenshot]({{ site.url }}/assets/cognito-identity-pool/identity-pool-created.png)
