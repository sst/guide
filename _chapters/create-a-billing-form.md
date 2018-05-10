---
layout: post
title: Create a Billing Form
date: 2018-03-23 00:00:00
description: We will create a billing form in our React app using the Stripe React SDK. We will use the CardElement to let the user input their credit card details and call the createToken method to generate a token that we can pass to our serverless billing API.
context: true
comments_id: create-a-billing-form/186
---

Now our settings page is going to have a form that will take a user's credit card details, get a stripe token and call our billing API with it. Let's start by adding the Stripe React SDK to our project.

<img class="code-marker" src="/assets/s.png" />From our project root, run the following.

``` bash
$ npm install --save react-stripe-elements
```

Next let's create our billing form component.

<img class="code-marker" src="/assets/s.png" />Add the following to a new file in `src/components/BillingForm.js`.

{% raw %}
``` coffee
import React, { Component } from "react";
import { FormGroup, FormControl, ControlLabel } from "react-bootstrap";
import { CardElement, injectStripe } from "react-stripe-elements";
import LoaderButton from "./LoaderButton";
import "./BillingForm.css";

class BillingForm extends Component {
  constructor(props) {
    super(props);

    this.state = {
      name: "",
      storage: "",
      isProcessing: false,
      isCardComplete: false
    };
  }

  validateForm() {
    return (
      this.state.name !== "" &&
      this.state.storage !== "" &&
      this.state.isCardComplete
    );
  }

  handleFieldChange = event => {
    this.setState({
      [event.target.id]: event.target.value
    });
  }

  handleCardFieldChange = event => {
    this.setState({
      isCardComplete: event.complete
    });
  }

  handleSubmitClick = async event => {
    event.preventDefault();

    const { name } = this.state;

    this.setState({ isProcessing: true });

    const { token, error } = await this.props.stripe.createToken({ name });

    this.setState({ isProcessing: false });

    this.props.onSubmit(this.state.storage, { token, error });
  }

  render() {
    const loading = this.state.isProcessing || this.props.loading;

    return (
      <form className="BillingForm" onSubmit={this.handleSubmitClick}>
        <FormGroup bsSize="large" controlId="storage">
          <ControlLabel>Storage</ControlLabel>
          <FormControl
            min="0"
            type="number"
            value={this.state.storage}
            onChange={this.handleFieldChange}
            placeholder="Number of notes to store"
          />
        </FormGroup>
        <hr />
        <FormGroup bsSize="large" controlId="name">
          <ControlLabel>Cardholder&apos;s name</ControlLabel>
          <FormControl
            type="text"
            value={this.state.name}
            onChange={this.handleFieldChange}
            placeholder="Name on the card"
          />
        </FormGroup>
        <ControlLabel>Credit Card Info</ControlLabel>
        <CardElement
          className="card-field"
          onChange={this.handleCardFieldChange}
          style={{
            base: { fontSize: "18px", fontFamily: '"Open Sans", sans-serif' }
          }}
        />
        <LoaderButton
          block
          bsSize="large"
          type="submit"
          text="Purchase"
          isLoading={loading}
          loadingText="Purchasing…"
          disabled={!this.validateForm()}
        />
      </form>
    );
  }
}

export default injectStripe(BillingForm);
```
{% endraw %}

Let's quickly go over what we are doing here:

- To begin with we are going to wrap our component with a Stripe module using the `injectStripe` HOC. This gives our component access to the `this.props.stripe.createToken` method.

- As for the fields in our form, we have input field of type `number` that allows a user to enter the number of notes they want to store. We also take the name on the credit card. These are stored in the state through the `this.handleFieldChange` method.

- The credit card number form is provided by the Stripe React SDK through the `CardElement` component that we import in the header.

- The submit button has a loading state that is set to true when we call Stripe to get a token and when we call our billing API. However, since our Settings container is calling the billing API we use the `this.props.loading` to set the state of the button from the Settings container.

- We also validate this form by checking if the name, the number of notes, and the card details are complete. For the card details, we use the CardElement's `onChange` method.

- Finally, once the user completes and submits the form we make a call to Stripe by passing in the credit card name and the credit card details (this is handled by the Stripe SDK). We call the `this.props.stripe.createToken` method and in return we get the token or an error back. We simply pass this and the number of notes to be stored to the settings page via the `this.props.onSubmit` method. We will be setting this up shortly.

You can read more about how to use the [React Stripe Elements here](https://github.com/stripe/react-stripe-elements).

Also, let's add some styles to the card field so it matches the rest of our UI.

<img class="code-marker" src="/assets/s.png" />Create a file at `src/components/BillingForm.css`.

``` css
.BillingForm .card-field {
  margin-bottom: 15px;
  background-color: white;
  padding: 11px 16px;
  border-radius: 6px;
  border: 1px solid #CCC;
  box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
  line-height: 1.3333333;
}

.BillingForm .card-field.StripeElement--focus {
  box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 8px rgba(102, 175, 233, .6);
  border-color: #66AFE9;
}
```

### Commit the Changes

<img class="code-marker" src="/assets/s.png" />Let's quickly commit these to Git.

``` bash
$ git add .
$ git commit -m "Adding a billing form"
```

Next we'll plug our form into the settings page.
