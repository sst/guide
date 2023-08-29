---
layout: post
title: Create a Billing Form
date: 2017-01-31 12:00:00
lang: en
description: We will create a billing form in our React app using the Stripe React SDK. We will use the CardElement to let the user input their credit card details and call the createToken method to generate a token that we can pass to our serverless billing API.
ref: create-a-billing-form
comments_id: create-a-billing-form/186
---

Now our settings page is going to have a form that will take a user's credit card details, get a stripe token and call our billing API with it. Let's start by adding the Stripe React SDK to our project.

{%change%} Run the following **in the `packages/frontend/` directory**.

```bash
$ pnpm add --save @stripe/react-stripe-js
```

Next let's create our billing form component.

{%change%} Add the following to a new file in `src/components/BillingForm.tsx`.

{% raw %}

```tsx
import React, { useState } from "react";
import Form from "react-bootstrap/Form";
import Stack from "react-bootstrap/Stack";
import { useFormFields } from "../lib/hooksLib";
import { Token, StripeError } from "@stripe/stripe-js";
import LoaderButton from "../components/LoaderButton";
import { CardElement, useStripe, useElements } from "@stripe/react-stripe-js";
import "./BillingForm.css";

export interface BillingFormType {
  isLoading: boolean;
  onSubmit: (
    storage: string,
    info: { token?: Token; error?: StripeError }
  ) => Promise<void>;
}

export function BillingForm({ isLoading, onSubmit }: BillingFormType) {
  const stripe = useStripe();
  const elements = useElements();
  const [fields, handleFieldChange] = useFormFields({
    name: "",
    storage: "",
  });
  const [isProcessing, setIsProcessing] = useState(false);
  const [isCardComplete, setIsCardComplete] = useState(false);

  isLoading = isProcessing || isLoading;

  function validateForm() {
    return (
      stripe &&
      elements &&
      fields.name !== "" &&
      fields.storage !== "" &&
      isCardComplete
    );
  }

  async function handleSubmitClick(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!stripe || !elements) {
      // Stripe.js has not loaded yet. Make sure to disable
      // form submission until Stripe.js has loaded.
      return;
    }

    if (!elements.getElement(CardElement)) {
      return;
    }

    setIsProcessing(true);

    const cardElement = elements.getElement(CardElement);

    if (!cardElement) {
      return;
    }

    const { token, error } = await stripe.createToken(cardElement);

    setIsProcessing(false);

    onSubmit(fields.storage, { token, error });
  }

  return (
    <Form className="BillingForm" onSubmit={handleSubmitClick}>
      <Form.Group controlId="storage">
        <Form.Label>Storage</Form.Label>
        <Form.Control
          min="0"
          size="lg"
          type="number"
          value={fields.storage}
          onChange={handleFieldChange}
          placeholder="Number of notes to store"
        />
      </Form.Group>
      <hr />
      <Stack gap={3}>
        <Form.Group controlId="name">
          <Form.Label>Cardholder&apos;s name</Form.Label>
          <Form.Control
            size="lg"
            type="text"
            value={fields.name}
            onChange={handleFieldChange}
            placeholder="Name on the card"
          />
        </Form.Group>
        <div>
          <Form.Label>Credit Card Info</Form.Label>
          <CardElement
            className="card-field"
            onChange={(e) => setIsCardComplete(e.complete)}
            options={{
              style: {
                base: {
                  fontSize: "16px",
                  fontWeight: "400",
                  color: "#495057",
                  fontFamily: "'Open Sans', sans-serif",
                },
              },
            }}
          />
        </div>
        <LoaderButton
          size="lg"
          type="submit"
          isLoading={isLoading}
          disabled={!validateForm()}
        >
          Purchase
        </LoaderButton>
      </Stack>
    </Form>
  );
}
```

{% endraw %}

Let's quickly go over what we are doing here:

- To begin with we are getting a reference to the Stripe object by calling `useStripe`.

- As for the fields in our form, we have input field of type `number` that allows a user to enter the number of notes they want to store. We also take the name on the credit card. These are stored in the state through the `handleFieldChange` method that we get from our `useFormFields` custom React Hook.

- The credit card number form is provided by the Stripe React SDK through the `CardElement` component that we import in the header.

- The submit button has a loading state that is set to true when we call Stripe to get a token and when we call our billing API. However, since our Settings container is calling the billing API we use the `props.isLoading` to set the state of the button from the Settings container.

- We also validate this form by checking if the name, the number of notes, and the card details are complete. For the card details, we use the `CardElement`'s `onChange` method.

- Finally, once the user completes and submits the form we make a call to Stripe by passing in the `CardElement`. It uses this to generate a token for the specific call. We simply pass this and the number of notes to be stored to the settings page via the `onSubmit` method. We will be setting this up shortly.

You can read more about how to use the [React Stripe SDK here](https://github.com/stripe/react-stripe-js).

Also, let's add some styles to the card field so it matches the rest of our UI.

{%change%} Create a file at `src/components/BillingForm.css`.

```css
.BillingForm .card-field {
  line-height: 1.5;
  padding: 0.65rem 0.75rem;
  background-color: var(--bs-body-bg);
  border: 1px solid var(--bs-border-color);
  border-radius: var(--bs-border-radius-lg);
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.BillingForm .card-field.StripeElement--focus {
  outline: 0;
  border-color: #86B7FE;
  box-shadow: 0 0 0 .25rem rgba(13, 110, 253, 0.25);
}
```

These styles might look complicated. But we are just copying them from the other form fields on the page to make sure that the card field looks like them.

Next we'll plug our form into the settings page.
