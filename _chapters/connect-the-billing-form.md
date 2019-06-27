---
layout: post
title: Connect the Billing Form
date: 2018-03-24 00:00:00
lang: en
description: To add our Stripe billing form to our React app container we need to wrap it inside a StripeProvider component. We also need to include Stripe.js in our HTML page.
context: true
ref: connect-the-billing-form
comments_id: connect-the-billing-form/187
---

Now all we have left to do is to connect our billing form to our billing API.

Let's start by including Stripe.js in our HTML.

<img class="code-marker" src="/assets/s.png" />Append the following the the `<head>` block in our `public/index.html`.

``` html
<script src="https://js.stripe.com/v3/"></script>
```

<img class="code-marker" src="/assets/s.png" />Replace our `render` method in `src/containers/Settings.js` with this.

``` coffee
handleFormSubmit = async (storage, { token, error }) => {
  if (error) {
    alert(error);
    return;
  }

  this.setState({ isLoading: true });

  try {
    await this.billUser({
      storage,
      source: token.id
    });

    alert("Your card has been charged successfully!");
    this.props.history.push("/");
  } catch (e) {
    alert(e);
    this.setState({ isLoading: false });
  }
}

render() {
  return (
    <div className="Settings">
      <StripeProvider apiKey={config.STRIPE_KEY}>
        <Elements>
          <BillingForm
            loading={this.state.isLoading}
            onSubmit={this.handleFormSubmit}
          />
        </Elements>
      </StripeProvider>
    </div>
  );
}
```

<img class="code-marker" src="/assets/s.png" />And add the following to the header.

``` js
import { Elements, StripeProvider } from "react-stripe-elements";
import BillingForm from "../components/BillingForm";
import config from "../config";
import "./Settings.css";
```

We are adding the `BillingForm` component that we previously created here and passing in the `loading` and `onSubmit` prop that we referenced in the last chapter. In the `handleFormSubmit` method, we are checking if the Stripe method from the last chapter returned an error. And if things looked okay then we call our billing API and redirect to the home page after letting the user know.

An important detail here is about the `StripeProvider` and the `Elements` component that we are using. The `StripeProvider` component let's the Stripe SDK know that we want to call the Stripe methods using `config.STRIPE_KEY`. And it needs to wrap around at the top level of our billing form. Similarly, the `Elements` component needs to wrap around any component that is going to be using the `CardElement` Stripe component.

Finally, let's handle some styles for our settings page as a whole.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/containers/Settings.css`.

``` css
@media all and (min-width: 480px) {
  .Settings {
    padding: 60px 0;
  }

  .Settings form {
    margin: 0 auto;
    max-width: 480px;
  }
}
```

This ensures that our form displays properly for larger screens.

![Settings screen with billing form screenshot](/assets/part2/settings-screen-with-billing-form.png)

And that's it. We are ready to test our Stripe form. Head over to your browser and try picking the number of notes you want to store and use the following for your card details:

- A Stripe test card number is `4242 4242 4242 4242`.
- You can use any valid expiry date, security code, and zip code.
- And set any name.

You can read more about the Stripe test cards in the [Stripe API Docs here](https://stripe.com/docs/testing#cards).

If everything is set correctly, you should see the success message and you'll be redirected to the homepage.

![Settings screen billing success screenshot](/assets/part2/settings-screen-billing-success.png)

### Commit the Changes

<img class="code-marker" src="/assets/s.png" />Let's quickly commit these to Git.

``` bash
$ git add .
$ git commit -m "Connecting the billing form"
```

Next, we'll set up automatic deployments for our React app using a service called [Netlify](https://www.netlify.com). This will be fairly similar to what we did for our serverless backend API.
