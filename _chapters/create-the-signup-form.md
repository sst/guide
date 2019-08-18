---
layout: post
title: Create the Signup Form
date: 2017-01-20 00:00:00
lang: en
ref: create-the-signup-form
description: We are going to create a signup page for our React.js app. To sign up users with Amazon Cognito, we need to create a form that allows users to enter a cofirmation code that is emailed to them.
context: true
comments_id: create-the-signup-form/52
---

Let's start by creating the signup form that'll get the user's email and password.

### Add the Container

<img class="code-marker" src="/assets/s.png" />Create a new container at `src/containers/Signup.js` with the following.

``` javascript
import React, { useReducer } from "react";
import {
  HelpBlock,
  FormGroup,
  FormControl,
  ControlLabel
} from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
import "./Signup.css";

function reducer(state, action) {
  switch (action.type) {
    case "change":
      return {
        ...state,
        [action.field]: action.value
      };
    case "submitting":
    case "confirming":
      return {
        ...state,
        isLoading: true
      };
    case "submitted":
      return {
        ...state,
        isLoading: false,
        newUser: action.newUser
      };
    case "submit-failed":
    case "confirm-failed":
      return {
        ...state,
        isLoading: false
      };
    default:
      throw new Error();
  }
}

export default function Signup(props) {
  const [state, dispatch] = useReducer(reducer, {
    email: "",
    password: "",
    newUser: null,
    isLoading: false,
    confirmPassword: "",
    confirmationCode: ""
  });

  function validateForm() {
    return (
      state.email.length > 0 &&
      state.password.length > 0 &&
      state.password === state.confirmPassword
    );
  }

  function validateConfirmationForm() {
    return state.confirmationCode.length > 0;
  }

  function handleChange(event) {
    dispatch({
      type: "change",
      field: event.target.id,
      value: event.target.value
    });
  }

  async function handleSubmit(event) {
    event.preventDefault();

    dispatch({ type: "submitting" });

    dispatch({ type: "submitted", newUser: "test" });
  }

  async function handleConfirmationSubmit(event) {
    event.preventDefault();

    dispatch({ type: "confirming" });
  }

  function renderConfirmationForm() {
    return (
      <form onSubmit={handleConfirmationSubmit}>
        <FormGroup controlId="confirmationCode" bsSize="large">
          <ControlLabel>Confirmation Code</ControlLabel>
          <FormControl
            autoFocus
            type="tel"
            value={state.confirmationCode}
            onChange={handleChange}
          />
          <HelpBlock>Please check your email for the code.</HelpBlock>
        </FormGroup>
        <LoaderButton
          block
          bsSize="large"
          disabled={!validateConfirmationForm()}
          type="submit"
          isLoading={state.isLoading}
          text="Verify"
          loadingText="Verifying…"
        />
      </form>
    );
  }

  function renderForm() {
    return (
      <form onSubmit={handleSubmit}>
        <FormGroup controlId="email" bsSize="large">
          <ControlLabel>Email</ControlLabel>
          <FormControl
            autoFocus
            type="email"
            value={state.email}
            onChange={handleChange}
          />
        </FormGroup>
        <FormGroup controlId="password" bsSize="large">
          <ControlLabel>Password</ControlLabel>
          <FormControl
            value={state.password}
            onChange={handleChange}
            type="password"
          />
        </FormGroup>
        <FormGroup controlId="confirmPassword" bsSize="large">
          <ControlLabel>Confirm Password</ControlLabel>
          <FormControl
            value={state.confirmPassword}
            onChange={handleChange}
            type="password"
          />
        </FormGroup>
        <LoaderButton
          block
          bsSize="large"
          disabled={!validateForm()}
          type="submit"
          isLoading={state.isLoading}
          text="Signup"
          loadingText="Signing up…"
        />
      </form>
    );
  }

  return (
    <div className="Signup">
      {state.newUser === null ? renderForm() : renderConfirmationForm()}
    </div>
  );
}
```

REWRITE

Most of the things we are doing here are fairly straightforward but let's go over them quickly.

1. Since we need to show the user a form to enter the confirmation code, we are conditionally rendering two forms based on if we have a user object or not.

2. We are using the `LoaderButton` component that we created earlier for our submit buttons.

3. Since we have two forms we have two validation methods called `validateForm` and `validateConfirmationForm`.

4. We are setting the `autoFocus` flags on the email and the confirmation code fields.

5. For now our `handleSubmit` and `handleConfirmationSubmit` don't do a whole lot besides setting the `isLoading` state and a dummy value for the `newUser` state.

<img class="code-marker" src="/assets/s.png" />Also, let's add a couple of styles in `src/containers/Signup.css`.

``` css
@media all and (min-width: 480px) {
  .Signup {
    padding: 60px 0;
  }

  .Signup form {
    margin: 0 auto;
    max-width: 320px;
  }
}

.Signup form span.help-block {
  font-size: 14px;
  padding-bottom: 10px;
  color: #999;
}
```

### Add the Route

<img class="code-marker" src="/assets/s.png" />Finally, add our container as a route in `src/Routes.js` below our login route. We are using the `AppliedRoute` component that we created in the [Add the session to the state]({% link _chapters/add-the-session-to-the-state.md %}) chapter.

``` coffee
<AppliedRoute path="/signup" exact component={Signup} props={childProps} />
```

And include our component in the header.

``` javascript
import Signup from "./containers/Signup";
```

Now if we switch to our browser and navigate to the signup page we should see our newly created form. Our form doesn't do anything when we enter in our info but you can still try to fill in an email address, password, and the confirmation code. It'll give you an idea of how the form will behave once we connect it to Cognito.

![Signup page added screenshot](/assets/signup-page-added.png)

Next, let's connect our signup form to Amazon Cognito.
