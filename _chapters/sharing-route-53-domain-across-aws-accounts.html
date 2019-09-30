Our `my-cart-app` has an API Gateway endpoint. In this chapter, we are going to look at how to set up custom domain for the API in each of our environment.

The custom domain scheme we are going to follow is:

- `prod` stage ⇒ api.my-cart-app.com
- `dev` stage ⇒ dev.api.my-cart-app.com

# Setup domain for prod

Note `prod` and `dev` are deployed to different AWS accounts. Assume we are hosting the domain [my-cart-app.com](http://my-cart-app.com) in the `Production` account. We can easily configure the custom domain for `prod`'s API endpoint.  Read [Set custom domains through Seed] to get familiar on how to create custom domains for your API Gateway endpoint.

# Setup domain for dev

We are going to delegate the subdomain `[dev.api.my-cart-app.com](http://dev.api.my-cart-app.com)` to be hosted in the `Development` account. As you follow the steps, whenever you are in doubt of which account the a step is performed in, pay attention to the account name shown at the top right corner of the screenshot.

First, go into your Route 53 console in your `Development` account:

[](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-1.png)

Select **Hosted zones** on the left menu. Then select **Create Hosted Zone**.

[](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-2.png)

Select **Create Hosted Zone** at the top. Enter:

- **Domain Name**: dev.api.my-cart-app.com

Then select **Create**.

[](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-3.png)

Select the zone you just created.

[](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-4.png)

Select on the row with **NS** type. And copy the 4 lines in the **Value** field. We need this in the steps after.

[](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-5.png)

Now, switch to the `Production` where the domain was hosted. And go into Route 53 console.

Select the domain.

[](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-6.png)

Select **Create Record Set**.

[](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-7.png)

Fill in:

- **Name**: dev.api
- **Type**: NS - Name server

And paste the 4 lines in the **Value** field.

Select **Create**.

[](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-8.png)

You should see a new `dev.api.my-cart-app.com` row in the table.

[](/assets/best-practices/sharing-route-53-domain-across-aws-accounts-9.png)

What we just did now is delegating the `dev.api` subdomain of `[my-cart-app.com](http://my-cart-app.com)` to our `Development` account. Now you can follow the [Set custom domains through Seed] chapter to set up `[dev.api.my-cart-app.com](http://dev.api.my-cart-app.com)` for the API Gateway endpoint for the `dev` stage.
