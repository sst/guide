---
layout: post
title: Handle Forgot and Reset Password
description: Use the AWS Amplify Auth.forgotPassword method to support forgot password functionality in our Serverless React app. This triggers Cognito to help our users reset their password.
date: 2018-04-14 00:00:00
code: user-management
comments_id: handle-forgot-and-reset-password/506
---

In our [Serverless notes app](https://demo.serverless-stack.com) we've used [Cognito User Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) to sign up and login our users. In the frontend we've used [AWS Amplify](https://aws-amplify.github.io/) in our React app. However, if our users have forgotten their passwords, we need to have a way for them to reset their password. In this chapter we will look at how to do this.

The version of the notes app used in this chapter is hosted in a:

- Separate GitHub repository: [**{{ site.frontend_user_mgmt_github_repo }}**]({{ site.frontend_user_mgmt_github_repo }})
- And can be accessed through: [**https://demo-user-mgmt.serverless-stack.com**](https://demo-user-mgmt.serverless-stack.com)

Let's look at the main changes we need to make to allow users to reset their password.

### Add a Reset Password Form

<img class="code-marker" src="/assets/s.png" />We are going to create a `src/containers/ResetPassword.js`.

```coffee
import React, { Component } from "react";
import { Auth } from "aws-amplify";
import { Link } from "react-router-dom";
import {
  HelpBlock,
  FormGroup,
  Glyphicon,
  FormControl,
  ControlLabel
} from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
import "./ResetPassword.css";

export default function ResetPassword() {
  const [fields, setFields] = useFormFields({
    code: "",
    email: "",
    password: "",
    confirmPassword: ""
  });
  const [codeSent, setCodeSent] = useState(false);
  const [confirmed, setConfirmed] = useState(false);
  const [isConfirming, setIsConfirming] = useState(false);
  const [isSendingCode, setIsSendingCode] = useState(false);

  function validateCodeForm() {
    return fields.email.length > 0;
  }
  function validateResetForm() {
    return (
      fields.code.length > 0 &&
      fields.password.length > 0 &&
      fields.password === fields.confirmPassword
    );
  }

  async function handleSendCodeClick(event) {
    event.preventDefault();

    setIsSendingCode(true);

    try {
      await Auth.forgotPassword(fields.email);
      setCodeSent(true);
    } catch (error) {
      alert(error.message);
      setIsSendingCode(false);
    }
  }

  async function handleConfirmClick(event) {
    event.preventDefault();

    setIsConfirming(true);

    try {
      await Auth.forgotPasswordSubmit(
        fields.email,
        fields.code,
        fields.password
      );
      setConfirmed(true);
    } catch (error) {
      alert(error.message);
      setIsConfirming(false);
    }
  }

  function renderRequestCodeForm() {
    return (
      <form onSubmit={handleSendCodeClick}>
        <FormGroup bsSize="large" controlId="email">
          <ControlLabel>Email</ControlLabel>
          <FormControl
            autoFocus
            type="email"
            value={fields.email}
            onChange={setFields}
          />
        </FormGroup>
        <LoaderButton
          block
          type="submit"
          bsSize="large"
          isLoading={isSendingCode}
          disabled={!validateCodeForm()}
        >
          Send Confirmation
        </LoaderButton>
      </form>
    );
  }

  function renderConfirmationForm() {
    return (
      <form onSubmit={handleConfirmClick}>
        <FormGroup bsSize="large" controlId="code">
          <ControlLabel>Confirmation Code</ControlLabel>
          <FormControl
            autoFocus
            type="tel"
            value={fields.code}
            onChange={setFields}
          />
          <HelpBlock>
            Please check your email ({fields.email}) for the confirmation code.
          </HelpBlock>
        </FormGroup>
        <hr />
        <FormGroup bsSize="large" controlId="password">
          <ControlLabel>New Password</ControlLabel>
          <FormControl
            type="password"
            value={fields.password}
            onChange={setFields}
          />
        </FormGroup>
        <FormGroup bsSize="large" controlId="confirmPassword">
          <ControlLabel>Confirm Password</ControlLabel>
          <FormControl
            type="password"
            value={fields.confirmPassword}
            onChange={setFields}
          />
        </FormGroup>
        <LoaderButton
          block
          type="submit"
          bsSize="large"
          isLoading={isConfirming}
          disabled={!validateResetForm()}
        >
          Confirm
        </LoaderButton>
      </form>
    );
  }

  function renderSuccessMessage() {
    return (
      <div className="success">
        <Glyphicon glyph="ok" />
        <p>Your password has been reset.</p>
        <p>
          <Link to="/login">Click here to login with your credentials.</Link>
        </p>
      </div>
    );
  }

  return (
    <div className="ResetPassword">
      {!codeSent
        ? renderRequestCodeForm()
        : !confirmed
        ? renderConfirmationForm()
        : renderSuccessMessage()}
    </div>
  );
}
```

Let's quickly go over the flow here:

- We ask the user to put in the email address for their account in the `renderRequestCodeForm()`.
- Once the user submits this form, we start the process by calling `Auth.forgotPassword(fields.email)`. Where `Auth` is a part of the AWS Amplify library.
- This triggers Cognito to send a verification code to the specified email address.
- Then we present a form where the user can input the code that Cognito sends them. This form is rendered in `renderConfirmationForm()`. And it also allows the user to put in their new password.
- Once they submit this form with the code and their new password, we call `Auth.forgotPasswordSubmit(fields.email, fields.code, fields.password)`. This resets the password for the account.
- Finally, we show the user a sign telling them that their password has been successfully reset. We also link them to the login page where they can login using their new details.

Let's also add a couple of styles.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/containers/ResetPassword.css`.

```css
@media all and (min-width: 480px) {
  .ResetPassword {
    padding: 60px 0;
  }

  .ResetPassword form {
    margin: 0 auto;
    max-width: 320px;
  }

  .ResetPassword .success {
    max-width: 400px;
  }
}

.ResetPassword .success {
  margin: 0 auto;
  text-align: center;
}
.ResetPassword .success .glyphicon {
  color: grey;
  font-size: 30px;
  margin-bottom: 30px;
}
```

### Add the Route

Finally, let's link this up with the rest of our app.

<img class="code-marker" src="/assets/s.png" />Add the route to `src/Routes.js`.

```html
<UnauthenticatedRoute
  path="/login/reset"
  exact
  component="{ResetPassword}"
  appProps="{appProps}"
/>
```

<img class="code-marker" src="/assets/s.png" />And import it in the header.

```coffee
import ResetPassword from "./containers/ResetPassword";
```

### Link from the Login Page

Now we want to make sure that our users are directed to this page when they are trying to login.

<img class="code-marker" src="/assets/s.png" />So let's add a link in our `src/containers/Login.js`. Add it above our login button.

```coffee
<Link to="/login/reset">Forgot password?</Link>
```

<img class="code-marker" src="/assets/s.png" />And import the `Link` component in the header.

```coffee
import { Link } from "react-router-dom";
```

<img class="code-marker" src="/assets/s.png" />And finally add some style to the link by adding the following to `src/containers/Login.css`

```css
.Login form a {
  margin-bottom: 15px;
  display: block;
  font-size: 14px;
```

That's it! We should now be able to navigate to `/login/reset` or go to it from the login page in case we need to reset our password.

![Login page forgot password link screenshot](/assets/user-management/login-page-forgot-password-link.png)

And from there they can put in their email to reset their password.

![Forgot password page screenshot](/assets/user-management/forgot-password-page.png)

Next, let's look at how our logged in users can change their password.
