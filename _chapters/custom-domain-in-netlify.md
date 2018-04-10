---
layout: post
title: Custom Domains in Netlify
date: 2017-05-30 00:00:00
description:
comments_id:
---

Now that we have our first deployment, let's configure a custom domain for our app through Netlify. This step is assuming you have a domain in Route 53 back from the first part of the tutorial.

### Pick a Netlify Site Name

From the project page in Netlify, hit **Site settings**.

- Screenshot

Under **Site information** hit **Change site name**.

- Screenshot

The site names as global, so pick a unique one. In our case we are using `serverless-stack-demo`. And hit **Save**.

- Screenshot

This means that our Netlify site URL is now going to be `https://serverless-stack-demo.netlify.com`. Make a note of this as we will use this later in this chapter.

### Domain Settings in Netlify

Next hit **Domain management** from the side panel.

- Screenshot

And hit **Add custom domain**.

- Screenshot

Type in the name of our domain, for example it might be `my-serverless-app.com`. And hit **Save**.

- Screenshot

This will automatically add the www version as well and will ask you to configure your DNS.

- Screenshot

### DNS Settings in Route 53

To do this we need to head back to the [AWS Console](https://console.aws.amazon.com/). and search for Route 53 as the service.

- Screenshot

Click on **Hosted zones**.

- Screenshot

And select the domain we want to configure.

- Screenshot

Here click on **Create Record Set**.

- Screenshot

Select **Type** as **A - IPv4 address** and set the **Value** to **104.198.14.52**. And hit **Save Record Set**.

- Screenshot

Next hit **Create Record Set** again.

- Screenshot

Set **Name** to `www`, **Type** to **CNAME - Canonical name**, and the value to the Netlify site name as we noted above. In our case it is `https://serverless-stack-demo.netlify.com`. Hit **Save Record Set**.

- Screenshot

And give the DNS around 30 minutes to update.

### Configure SSL

From the side panel hit **HTTPS**.

- Screenshot

And hit **Verify DNS configuration**.

- Screenshot

If everything has been confgured properly, you should be able to hit **Let's Encrypt Certificate**.

- Screenshot

This process might take around 10 minutes to complete. But once complete, scroll down and hit **Force HTTPS**.

- Screenshot

This forces your users to only use HTTPS to communicate with your app.

Now if you head over to your browser and go to your custom domain, your notes app should be up and running!

- Screenshot

Now we have our production deploy. But we haven't had a chance to go through our workflow just yet. Let's take a look at that next.
