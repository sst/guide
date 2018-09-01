---
layout: post
title: Custom Domains in Netlify
date: 2018-03-28 00:00:00
description: To configure your React app with custom domains on Netlify and AWS, you need to point the Route 53 DNS to Netlify. Create a new Record set, add an A Record, and a CNAME for your new Netlify project.
context: true
comments_id: custom-domains-in-netlify/191
---

Now that we have our first deployment, let's configure a custom domain for our app through Netlify. This step is assuming you have a domain in Route 53 back from the first part of the tutorial.

### Pick a Netlify Site Name

From the project page in Netlify, hit **Site settings**.

![Netlify hit Site settings screenshot](/assets/part2/netlify-hit-site-settings.png)

Under **Site information** hit **Change site name**.

![Hit Change site name screenshot](/assets/part2/hit-change-site-name.png)

The site names are global, so pick a unique one. In our case we are using `serverless-stack-2-client`. And hit **Save**.

![Save change site name screenshot](/assets/part2/save-change-site-name.png)

This means that our Netlify site URL is now going to be `https://serverless-stack-2-client.netlify.com`. Make a note of this as we will use this later in this chapter.

### Domain Settings in Netlify

Next hit **Domain management** from the side panel.

![Select Domain management screenshot](/assets/part2/select-domain-management.png)

And hit **Add custom domain**.

![Click Add custom domain screenshot](/assets/part2/click-add-custom-domain.png)

Type in the name of our domain, for example it might be `demo-serverless-stack.com`. And hit **Save**.

![Enter custom domain screenshot](/assets/part2/enter-custom-domain.png)

This will automatically add the www version as well and will ask you to configure your DNS.

![Custom domain settings added screenshot](/assets/part2/custom-domain-settings-added.png)

### DNS Settings in Route 53

To do this we need to head back to the [AWS Console](https://console.aws.amazon.com/). and search for Route 53 as the service.

![Select Route 53 service screenshot](/assets/part2/select-route-53-service.png)

Click on **Hosted zones**.

![Select Route 53 hosted zones screenshot](/assets/part2/select-route-53-hosted-zones.png)

And select the domain we want to configure.

![Select Route 53 domain screenshot](/assets/part2/select-route-53-domain.png)

Here click on **Create Record Set**.

![Create first Route 53 record set screenshot](/assets/part2/create-first-route-53-record-set.png)

Select **Type** as **A - IPv4 address** and set the **Value** to **104.198.14.52**. And hit **Create**. We get this IP from the [Netlify docs on adding custom domains](https://www.netlify.com/docs/custom-domains/).

![Add A record screenshot](/assets/part2/add-a-record.png)

Next hit **Create Record Set** again.

Set **Name** to `www`, **Type** to **CNAME - Canonical name**, and the value to the Netlify site name as we noted above. In our case it is `https://serverless-stack-2-client.netlify.com`. Hit **Create**.

![Add CNAME record screenshot](/assets/part2/add-cname-record.png)

And give the DNS around 30 minutes to update.

### Configure SSL

Back in Netlify, hit **HTTPS** in the side panel. And hit **Verify DNS configuration**.

![Verify DNS configuration screenshot](/assets/part2/verify-dns-configuration.png)

If everything has been configured properly, you should be able to hit **Let's Encrypt Certificate**.

![Setup Let's Encrypt Certificate screenshot](/assets/part2/setup-lets-encrypt-certificate.png)

Next, confirm this by hitting **Provision certificate**.

![Select Provision certificate screenshot](/assets/part2/select-provision-certificate.png)

This process might take around 10 minutes to complete. But once complete, scroll down and hit **Force HTTPS**.

![Set Force HTTPS screenshot](/assets/part2/set-force-https.png)

This forces your users to only use HTTPS to communicate with your app.

Now if you head over to your browser and go to your custom domain, your notes app should be up and running!

![Notes app on custom domain screenshot](/assets/part2/notes-app-on-custom-domain.png)

We have our app in production but we haven't had a chance to go through our workflow just yet. Let's take a look at that next.
