---
layout: post
title: Sharing Route 53 domains across AWS accounts
description: 
date: 2019-10-02 00:00:00
comments_id: 
---

Our notes app has an API Gateway endpoint. In this chapter, we are going to look at how to set up custom domains for each of our environments.

We are going to setup the following custom domain scheme:

- `prod` ⇒ api.notes-app.com
- `dev` ⇒ dev.api.notes-app.com

### Setup domain for prod

Recall that `prod` and `dev` are deployed to separate AWS accounts. Assume we are hosting the domain `notes-app.com` in the `Production` account. We can easily configure the custom domain for `prod`'s API endpoint. You can read about [how to setup a custom domain for API Gateway here](https://seed.run/blog/how-to-set-up-a-custom-domain-name-for-api-gateway-in-your-serverless-app). Alternatively, you can easily [set this up through Seed](https://seed.run/docs/configuring-custom-domains).

TODO: ADD SEED CUSTOM DOMAIN SCREENSHOT

### Setup domain for dev

However, using the same domain for our dev environments takes an extra step. This is because the `dev` environment is in a separate AWS account.

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

Now we've delegated the `dev.api` subdomain of `notes-app.com` to our `Development` AWS account. You can now head over to your app or to Seed and [add this as a custom domain](https://seed.run/docs/configuring-custom-domains) for the `dev` stage.

TODO: ADD SEED CUSTOM DOMAIN SCREENSHOT
