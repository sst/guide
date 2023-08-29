---
layout: post
title: Allow Users to Change Passwords
description: Use the AWS Amplify Auth.changePassword method to support change password functionality in our Serverless React app. This triggers Cognito to help our users change their password.
date: 2018-04-15 00:00:00
code: user-management
comments_id: allow-users-to-change-passwords/507
---

For our [Serverless notes app](https://demo.sst.dev), we want to allow our users to change their password. Recall that we are using Cognito to manage our users and AWS Amplify in our React app. In this chapter we will look at how to do that.

For reference, we are using a forked version of the notes app with:

- A separate GitHub repository: [**{{ site.frontend_user_mgmt_github_repo }}**]({{ site.frontend_user_mgmt_github_repo }})
- And it can be accessed through: [**https://demo-user-mgmt.sst.dev**](https://demo-user-mgmt.sst.dev)

Let's start by editing our settings page so that our users can use to change their password.

### Add a Settings Page

{%change%} Replace the `return` statement in `src/containers/Settings.js` with.

```jsx
return (
  <div className="Settings">
    <LinkContainer to="/settings/email">
      <LoaderButton block bsSize="large">
        Change Email
      </LoaderButton>
    </LinkContainer>
    <LinkContainer to="/settings/password">
      <LoaderButton block bsSize="large">
        Change Password
      </LoaderButton>
    </LinkContainer>
    <hr />
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

{%change%} And import the following as well.

```jsx
import { LinkContainer } from "react-router-bootstrap";
import LoaderButton from "../components/LoaderButton";
```

All this does is add two links to a page that allows our users to change their password and email.

{%change%} Replace our `src/containers/Settings.css` with the following.

```css
@media all and (min-width: 480px) {
  .Settings {
    padding: 60px 0;
    margin: 0 auto;
    max-width: 480px;
  }

  .Settings > .LoaderButton:first-child {
    margin-bottom: 15px;
  }
}
```

![Settings page screenshot](/assets/user-management/settings-page.png)

### Change Password Form

Now let's create the form that allows our users to change their password.

{%change%} Add the following to `src/containers/ChangePassword.js`.

```jsx
import React, { useState } from "react";
import { Auth } from "aws-amplify";
import { useNavigate } from "react-router-dom";
import { FormGroup, FormControl, FormLabel } from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
import { useFormFields } from "../lib/hooksLib";
import { onError } from "../lib/errorLib";
import "./ChangePassword.css";

export default function ChangePassword() {
  const nav = useNavigate();
  const [fields, handleFieldChange] = useFormFields({
    password: "",
    oldPassword: "",
    confirmPassword: "",
  });
  const [isChanging, setIsChanging] = useState(false);

  function validateForm() {
    return (
      fields.oldPassword.length > 0 &&
      fields.password.length > 0 &&
      fields.password === fields.confirmPassword
    );
  }

  async function handleChangeClick(event) {
    event.preventDefault();

    setIsChanging(true);

    try {
      const currentUser = await Auth.currentAuthenticatedUser();
      await Auth.changePassword(
        currentUser,
        fields.oldPassword,
        fields.password
      );

      nav("/settings");
    } catch (error) {
      onError(error);
      setIsChanging(false);
    }
  }

  return (
    <div className="ChangePassword">
      <form onSubmit={handleChangeClick}>
        <FormGroup bsSize="large" controlId="oldPassword">
          <FormLabel>Old Password</FormLabel>
          <FormControl
            type="password"
            onChange={handleFieldChange}
            value={fields.oldPassword}
          />
        </FormGroup>
        <hr />
        <FormGroup bsSize="large" controlId="password">
          <FormLabel>New Password</FormLabel>
          <FormControl
            type="password"
            onChange={handleFieldChange}
            value={fields.password}
          />
        </FormGroup>
        <FormGroup bsSize="large" controlId="confirmPassword">
          <FormLabel>Confirm Password</FormLabel>
          <FormControl
            type="password"
            onChange={handleFieldChange}
            value={fields.confirmPassword}
          />
        </FormGroup>
        <LoaderButton
          block
          type="submit"
          bsSize="large"
          disabled={!validateForm()}
          isLoading={isChanging}
        >
          Change Password
        </LoaderButton>
      </form>
    </div>
  );
}
```

Most of this should be very straightforward. The key part of the flow here is that we ask the user for their current password along with their new password. Once they enter it, we can call the following:

```jsx
const currentUser = await Auth.currentAuthenticatedUser();
await Auth.changePassword(currentUser, fields.oldPassword, fields.password);
```

The above snippet uses the `Auth` module from Amplify to get the current user. And then uses that to change their password by passing in the old and new password. Once the `Auth.changePassword` method completes, we redirect the user to the settings page.

{%change%} Let's also add a couple of styles.

```css
@media all and (min-width: 480px) {
  .ChangePassword {
    padding: 60px 0;
  }

  .ChangePassword form {
    margin: 0 auto;
    max-width: 320px;
  }
}
```

{%change%} Let's add our new page to `src/Routes.js`.

```html
<Route
  path="/settings/password"
  element={
    <AuthenticatedRoute>
        <ChangePassword />
    </AuthenticatedRoute>
  }
/>
```

{%change%} And import it.

```jsx
import ChangePassword from "./containers/ChangePassword";
```

That should do it. The `/settings/password` page should allow us to change our password.

![Change password page screenshot](/assets/user-management/change-password-page.png)

Next, let's look at how to implement a change email form for our users.
