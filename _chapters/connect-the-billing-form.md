---
layout: post
title: Connect the Billing Form
date: 2017-01-31 18:00:00
lang: en
description: To add our Stripe billing form to our React app container we need to wrap it inside a StripeProvider component.
ref: connect-the-billing-form
comments_id: connect-the-billing-form/187
---

Now all we have left to do is to connect our billing form to our billing API.

{%change%} Replace our `return` statement in `src/containers/Settings.js` with this.

```jsx
async function handleFormSubmit(storage, { token, error }) {
  if (error) {
    onError(error);
    return;
  }

  setIsLoading(true);

  try {
    await billUser({
      storage,
      source: token.id,
    });

    alert("Your card has been charged successfully!");
    nav("/");
  } catch (e) {
    onError(e);
    setIsLoading(false);
  }
}

return (
  <div className="Settings">
    <Elements
      stripe={stripePromise}
      fonts={[
        {
          cssSrc:
            "https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700,800",
        },
      ]}
    >
      <BillingForm isLoading={isLoading} onSubmit={handleFormSubmit} />
    </Elements>
  </div>
);
```

{%change%} And add the following to the header.

```js
import { Elements } from "@stripe/react-stripe-js";
import BillingForm from "../components/BillingForm";
import "./Settings.css";
```

We are adding the `BillingForm` component that we previously created here and passing in the `isLoading` and `onSubmit` prop that we referenced in the previous chapter. In the `handleFormSubmit` method, we are checking if the Stripe method returned an error. And if things looked okay then we call our billing API and redirect to the home page after letting the user know.

To initialize the Stripe Elements we pass in the Stripe.js object that we loaded [a couple of chapters ago]({% link _chapters/add-stripe-keys-to-config.md %}). This Elements component needs to wrap around any Stripe React components.

The Stripe elements are loaded inside an [IFrame](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/iframe). So if we are using any custom fonts, we'll need to include them explicitly. Like we are doing above.

```jsx
<Elements
  fonts={[
    {
      cssSrc:
        "https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700,800",
    },
  ]}
>
```

Finally, let's handle some styles for our settings page as a whole.

{%change%} Create a file named `src/containers/Settings.css` and add the following.

```css
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

Now with our app nearly complete, we'll look at securing some the pages of our app that require a login. Currently if you visit a note page while you are logged out, it throws an ugly error.

![Note page logged out error screenshot](/assets/note-page-logged-out-error.png)

Instead, we would like it to redirect us to the login page and then redirect us back after we login. Let's look at how to do that next.
