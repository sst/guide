---
layout: post
title: Create a Login Page
date: 2017-01-13 00:00:00
lang: en
comments_id: create-a-login-page
description: We are going to add a login page to our React.js app. To create the login form we are using the FormGroup and FormControl React-Bootstrap components.
comments_id: create-a-login-page/71
---

Let's create a page where the users of our app can login with their credentials. When we created our User Pool we asked it to allow a user to sign in and sign up with their email as their username. We'll be touching on this further when we create the signup form.

So let's start by creating the basic form that'll take the user's email (as their username) and password.

### Add the Container

<img class="code-marker" src="/assets/s.png" />Create a new file `src/containers/Login.js` and add the following.

``` coffee
import React, { useState } from "react";
import { Button, FormGroup, FormControl, ControlLabel } from "react-bootstrap";
import "./Login.css";

export default function Login(props) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  function validateForm() {
    return email.length > 0 && password.length > 0;
  }

  function handleSubmit(event) {
    event.preventDefault();
  }

  return (
    <div className="Login">
      <form onSubmit={handleSubmit}>
        <FormGroup controlId="email" bsSize="large">
          <ControlLabel>Email</ControlLabel>
          <FormControl
            autoFocus
            type="email"
            value={email}
            onChange={e => setEmail(e.target.value)}
          />
        </FormGroup>
        <FormGroup controlId="password" bsSize="large">
          <ControlLabel>Password</ControlLabel>
          <FormControl
            value={password}
            onChange={e => setPassword(e.target.value)}
            type="password"
          />
        </FormGroup>
        <Button block bsSize="large" disabled={!validateForm()} type="submit">
          Login
        </Button>
      </form>
    </div>
  );
}
```

We are introducing a couple of new concepts in this.

1. Right at the top of our component, we are using the [useState hook](https://reactjs.org/docs/hooks-state.html) to store what the user enters in the form. The `useState` hook just gives you the current value of the variable you want to store in the state and a function to set the new value. If you are transitioning from Class components to using React Hooks, we've added [a chapter to help you understand how Hooks work]({% link _chapters/understanding-react-hooks.md %}).

2. We then connect the state to our two fields in the form using the `setEmail` and `setPassword` functions to store what the user types in — `e.target.value`. Once we set the new state, our component gets re-rendered. The variables `email` and `password` now have the new values.

3. We are setting the form controls to show the value of our two state variables `email` and `password`. In React, this pattern of displaying the current form value as a state variable and setting the new one when a user types something, is called a [Controlled Component](https://reactjs.org/docs/forms.html#controlled-components).

4. We are setting the `autoFocus` flag for our email field, so that when our form loads, it sets focus to this field.

5. We also link up our submit button with our state by using a validate function called `validateForm`. This simply checks if our fields are non-empty, but can easily do something more complicated.

6. Finally, we trigger our callback `handleSubmit` when the form is submitted. For now we are simply suppressing the browser's default behavior on submit but we'll do more here later.

<img class="code-marker" src="/assets/s.png" />Let's add a couple of styles to this in the file `src/containers/Login.css`.

``` css
@media all and (min-width: 480px) {
  .Login {
    padding: 60px 0;
  }

  .Login form {
    margin: 0 auto;
    max-width: 320px;
  }
}
```

These styles roughly target any non-mobile screen sizes.

### Add the Route

<img class="code-marker" src="/assets/s.png" />Now we link this container up with the rest of our app by adding the following line to `src/Routes.js` below our home `<Route>`.

``` coffee
<Route path="/login" exact component={Login} />
```

<img class="code-marker" src="/assets/s.png" />And include our component in the header.

``` javascript
import Login from "./containers/Login";
```

Now if we switch to our browser and navigate to the login page we should see our newly created form.

![Login page added screenshot](/assets/login-page-added.png)

Next, let's connect our login form to our AWS Cognito set up.
