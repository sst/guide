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

{%change%} From our project root, run the following.

``` bash
$ npm install --save react-stripe-elements
```

Next let's create our billing form component.

{%change%} Add the following to a new file in `src/components/BillingForm.js`.

{% raw %}
``` coffee
import React, { useState } from "react";
import Form from "react-bootstrap/Form";
import { CardElement, injectStripe } from "react-stripe-elements";
import LoaderButton from "./LoaderButton";
import { useFormFields } from "../libs/hooksLib";
import "./BillingForm.css";

function BillingForm({ isLoading, onSubmit, ...props }) {
  const [fields, handleFieldChange] = useFormFields({
    name: "",
    storage: "",
  });
  const [isProcessing, setIsProcessing] = useState(false);
  const [isCardComplete, setIsCardComplete] = useState(false);

  isLoading = isProcessing || isLoading;

  function validateForm() {
    return fields.name !== "" && fields.storage !== "" && isCardComplete;
  }

  async function handleSubmitClick(event) {
    event.preventDefault();

    setIsProcessing(true);

    const { token, error } = await props.stripe.createToken({
      name: fields.name,
    });

    setIsProcessing(false);

    onSubmit(fields.storage, { token, error });
  }

  return (
    <Form className="BillingForm" onSubmit={handleSubmitClick}>
      <Form.Group size="lg" controlId="storage">
        <Form.Label>Storage</Form.Label>
        <Form.Control
          min="0"
          type="number"
          value={fields.storage}
          onChange={handleFieldChange}
          placeholder="Number of notes to store"
        />
      </Form.Group>
      <hr />
      <Form.Group size="lg" controlId="name">
        <Form.Label>Cardholder&apos;s name</Form.Label>
        <Form.Control
          type="text"
          value={fields.name}
          onChange={handleFieldChange}
          placeholder="Name on the card"
        />
      </Form.Group>
      <Form.Label>Credit Card Info</Form.Label>
      <CardElement
        className="card-field"
        onChange={(e) => setIsCardComplete(e.complete)}
        style={{
          base: {
            fontSize: "16px",
            color: "#495057",
            fontFamily: "'Open Sans', sans-serif",
          },
        }}
      />
      <LoaderButton
        block
        size="lg"
        type="submit"
        isLoading={isLoading}
        disabled={!validateForm()}
      >
        Purchase
      </LoaderButton>
    </Form>
  );
}

export default injectStripe(BillingForm);
```
{% endraw %}

Let's quickly go over what we are doing here:

- To begin with we are going to wrap our component with a Stripe module using the `injectStripe` HOC. A [Higher-Order Component (or HOC)](https://reactjs.org/docs/higher-order-components.html), is one that takes a component and returns a new component. It wraps around a given component and can add additional functionality to it. In our case, this gives our component access to the `props.stripe.createToken` method.

  ``` javascript
  export default injectStripe(BillingForm)
  ```

- As for the fields in our form, we have input field of type `number` that allows a user to enter the number of notes they want to store. We also take the name on the credit card. These are stored in the state through the `handleFieldChange` method that we get from our `useFormFields` custom React Hook.

- The credit card number form is provided by the Stripe React SDK through the `CardElement` component that we import in the header.

- The submit button has a loading state that is set to true when we call Stripe to get a token and when we call our billing API. However, since our Settings container is calling the billing API we use the `props.isLoading` to set the state of the button from the Settings container.

- We also validate this form by checking if the name, the number of notes, and the card details are complete. For the card details, we use the CardElement's `onChange` method.

- Finally, once the user completes and submits the form we make a call to Stripe by passing in the credit card name and the credit card details (this is handled by the Stripe SDK). We call the `props.stripe.createToken` method and in return we get the token or an error back. We simply pass this and the number of notes to be stored to the settings page via the `onSubmit` method. We will be setting this up shortly.

You can read more about how to use the [React Stripe Elements here](https://github.com/stripe/react-stripe-elements).

Also, let's add some styles to the card field so it matches the rest of our UI.

{%change%} Create a file at `src/components/BillingForm.css`.

``` css
.BillingForm .card-field {
  line-height: 1.5;
  margin-bottom: 1rem;
  border-radius: 0.25rem;
  padding: 0.55rem 0.75rem;
  background-color: white;
  border: 1px solid #ced4da;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.BillingForm .card-field.StripeElement--focus {
  outline: 0;
  border-color: #80bdff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}
```

These styles might look complicated. But we are just copying them from the other form fields on the page to make sure that the card field looks like them.

Next we'll plug our form into the settings page.
