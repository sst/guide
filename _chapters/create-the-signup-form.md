---
layout: post
title: Create the Signup Form
date: 2017-01-20 00:00:00
lang: en
ref: create-the-signup-form
description: We are going to create a signup page for our React.js app. To sign up users with Amazon Cognito, we need to create a form that allows users to enter a confirmation code that is emailed to them.
comments_id: create-the-signup-form/52
---

Let's start by creating the signup form that'll get the user's email and password.

### Add the Container

{%change%} Create a new container at `src/containers/Signup.tsx` with the following.

```tsx
import React, { useState } from "react";
import Form from "react-bootstrap/Form";
import Stack from "react-bootstrap/Stack";
import { useNavigate } from "react-router-dom";
import { useFormFields } from "../lib/hooksLib";
import { useAppContext } from "../lib/contextLib";
import LoaderButton from "../components/LoaderButton";
import "./Signup.css";

export default function Signup() {
  const [fields, handleFieldChange] = useFormFields({
    email: "",
    password: "",
    confirmPassword: "",
    confirmationCode: "",
  });
  const nav = useNavigate();
  const { userHasAuthenticated } = useAppContext();
  const [isLoading, setIsLoading] = useState(false);
  const [newUser, setNewUser] = useState<null | string>(null);

  function validateForm() {
    return (
      fields.email.length > 0 &&
      fields.password.length > 0 &&
      fields.password === fields.confirmPassword
    );
  }

  function validateConfirmationForm() {
    return fields.confirmationCode.length > 0;
  }

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsLoading(true);
    setNewUser("test");
    setIsLoading(false);
  }

  async function handleConfirmationSubmit(
    event: React.FormEvent<HTMLFormElement>
  ) {
    event.preventDefault();
    setIsLoading(true);
  }

  function renderConfirmationForm() {
    return (
      <Form onSubmit={handleConfirmationSubmit}>
        <Stack gap={3}>
          <Form.Group controlId="confirmationCode">
            <Form.Label>Confirmation Code</Form.Label>
            <Form.Control
              size="lg"
              autoFocus
              type="tel"
              onChange={handleFieldChange}
              value={fields.confirmationCode}
            />
            <Form.Text muted>Please check your email for the code.</Form.Text>
          </Form.Group>
          <LoaderButton
            size="lg"
            type="submit"
            variant="success"
            isLoading={isLoading}
            disabled={!validateConfirmationForm()}
          >
            Verify
          </LoaderButton>
        </Stack>
      </Form>
    );
  }

  function renderForm() {
    return (
      <Form onSubmit={handleSubmit}>
        <Stack gap={3}>
          <Form.Group controlId="email">
            <Form.Label>Email</Form.Label>
            <Form.Control
              size="lg"
              autoFocus
              type="email"
              value={fields.email}
              onChange={handleFieldChange}
            />
          </Form.Group>
          <Form.Group controlId="password">
            <Form.Label>Password</Form.Label>
            <Form.Control
              size="lg"
              type="password"
              value={fields.password}
              onChange={handleFieldChange}
            />
          </Form.Group>
          <Form.Group controlId="confirmPassword">
            <Form.Label>Confirm Password</Form.Label>
            <Form.Control
              size="lg"
              type="password"
              onChange={handleFieldChange}
              value={fields.confirmPassword}
            />
          </Form.Group>
          <LoaderButton
            size="lg"
            type="submit"
            variant="success"
            isLoading={isLoading}
            disabled={!validateForm()}
          >
            Signup
          </LoaderButton>
        </Stack>
      </Form>
    );
  }

  return (
    <div className="Signup">
      {newUser === null ? renderForm() : renderConfirmationForm()}
    </div>
  );
}
```

Most of the things we are doing here are fairly straightforward but let's go over them quickly.

1. Since we need to show the user a form to enter the confirmation code, we are conditionally rendering two forms based on if we have a user object or not.

   ```jsx
   {
     newUser === null ? renderForm() : renderConfirmationForm();
   }
   ```

2. We are using the `LoaderButton` component that we created earlier for our submit buttons.

3. Since we have two forms we have two validation functions called `validateForm` and `validateConfirmationForm`.

4. We are setting the `autoFocus` flags on the email and the confirmation code fields.

   `<Form.Control autoFocus type="email" ... />`

5. For now our `handleSubmit` and `handleConfirmationSubmit` don't do a whole lot besides setting the `isLoading` state and a dummy value for the `newUser` state.

6. And you'll notice we are using the `useFormFields` custom React Hook that we [previously created]({% link _chapters/create-a-custom-react-hook-to-handle-form-fields.md %}) to handle our form fields.

   ```typescript
   const [fields, handleFieldChange] = useFormFields({
     email: "",
     password: "",
     confirmPassword: "",
     confirmationCode: "",
   });
   ```

{%change%} Also, let's add a couple of styles in `src/containers/Signup.css`.

```css
@media all and (min-width: 480px) {
  .Signup {
    padding: 60px 0;
  }

  .Signup form {
    margin: 0 auto;
    max-width: 320px;
  }
}
```

### Add the Route

{%change%} Finally, add our container as a route in `src/Routes.tsx` below our login route.

```tsx
<Route path="/signup" element={<Signup />} />
```

{%change%} And include our component in the header.

```typescript
import Signup from "./containers/Signup.tsx";
```

Now if we switch to our browser and navigate to the signup page we should see our newly created form. Our form doesn't do anything when we enter in our info but you can still try to fill in an email address, password, and confirmation password. 

![Signup page added screenshot](/assets/part2/signup-page-added.png)

Then, after hitting submit, you'll get the confirmation code form.  This'll give you an idea of how the form will behave once we connect it to Cognito.

![Signup page added screenshot](/assets/part2/signup-page-confirmation-code.png)

Next, let's connect our signup form to Amazon Cognito.
