---
layout: post
title: Sharing Route 53 domains across AWS accounts
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

Our notes app has an API Gateway endpoint. In this chapter, we are going to look at how to set up custom domains for each of our environments. Recall that our environments are split across multiple AWS accounts.

We are going to setup the following custom domain scheme:

- `prod` ⇒ api.notes-app.com
- `dev` ⇒ dev.api.notes-app.com

Assuming that our domain is hosted in our `Production` AWS account. We want to set it up so that our `Development` AWS account can use the above subdomain. This takes an extra setup.

### Delegate domains across AWS accounts

We are going to have to delegate the subdomain `dev.api.notes-app.com` to be hosted in the `Development` AWS account. Just a quick note, as you follow these steps, pay attention to the account name shown at the top right corner of the screenshot. It'll tell you which account we are working with.

First, go into your Route 53 console in your `Development` account.

TODO: UPDATE SCREENSHOTS

![](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-1.png)

Click **Hosted zones** in the left menu. Then select **Create Hosted Zone**.

![](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-2.png)

Select **Create Hosted Zone** at the top. Enter:

- **Domain Name**: dev.api.notes-app.com

Then click **Create**.

![](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-3.png)

Select the zone you just created.

![](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-4.png)

Click on the row with **NS** type. And copy the 4 lines in the **Value** field. We need this in the steps after.

![](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-5.png)

Now, switch to the `Production` account where the domain is hosted. And go into Route 53 console.

Select the domain.

![](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-6.png)

Click **Create Record Set**.

![](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-7.png)

Fill in:

- **Name**: dev.api
- **Type**: NS - Name server

And paste the 4 lines from above in the **Value** field.

Click **Create**.

![](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-8.png)

You should see a new `dev.api.notes-app.com` row in the table.

![](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-9.png)

TODO: UPDATE LINK

Now we've delegated the `dev.api` subdomain of `notes-app.com` to our `Development` AWS account. We'll be configuring our app to use [these domains in a later chapter].

Next, let's quickly look at how you'll be managing the cost and usage for your two AWS accounts.
