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

Now we need to specify what AWS resources are accessible for users with temporary credentials obtained from the identity pool.

Select **View Details**. Two **Role Summary** sections are expanded. The top section summarizes the permission policy for authenticated users, and the bottom section summarizes that for unauthenticated users.

Select **View Policy Document** in the top section. Then select **Edit**.

![Screenshot]({{ site.url }}/assets/cognito-user-pool/5.png)

It will warn you to read the documentation. Select **Ok** to edit.

![Screenshot]({{ site.url }}/assets/cognito-user-pool/6.png)

Add the following polity into the editor. Where `react-notes-app` is the name of our S3 bucket.

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
        "arn:aws:s3:::anomaly-notes-app/${cognito-identity.amazonaws.com:sub}*"
      ]
    }
  ]
}
{% endhighlight %}

Select **Allow**

![Screenshot]({{ site.url }}/assets/cognito-user-pool/7.png)
