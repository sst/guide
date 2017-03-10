---
layout: post
title: Create a Login Page
date: 2017-01-13 00:00:00
code: frontend
---

Let's create a page where the users of our app can login with their credentials. AWS Cognito needs a username and password to authenticate a user. To keep things simple we are going to use the user's email as their username (as opposed to asking them to create a username). We'll be touching on this further when we create the signup form.

So let's start by creating the basic form that'll take the user's email (as their username) and password.

### Add the Container

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a new file `src/containers/Login.js` and add the following.

``` coffee
import React, { Component } from 'react';
import {
  Button,
  FormGroup,
  FormControl,
  ControlLabel,
} from 'react-bootstrap';
import './Login.css';

export default class Login extends Component {
  constructor(props) {
    super(props);

    this.state = {
      username: '',
      password: '',
    };
  }

  validateForm() {
    return this.state.username.length > 0
      && this.state.password.length > 0;
  }

  handleChange = (event) => {
    this.setState({
      [event.target.id]: event.target.value
    });
  }

  handleSubmit = (event) => {
    event.preventDefault();
  }

  render() {
    return (
      <div className="Login">
        <form onSubmit={this.handleSubmit}>
          <FormGroup controlId="username" bsSize="large">
            <ControlLabel>Email</ControlLabel>
            <FormControl
              autoFocus
              type="email"
              value={this.state.username}
              onChange={this.handleChange} />
          </FormGroup>
          <FormGroup controlId="password" bsSize="large">
            <ControlLabel>Password</ControlLabel>
            <FormControl
              value={this.state.password}
              onChange={this.handleChange}
              type="password" />
          </FormGroup>
          <Button
            block
            bsSize="large"
            disabled={ ! this.validateForm() }
            type="submit">
            Login
          </Button>
        </form>
      </div>
    );
  }
}
```

We are introducing a couple of new concepts in this.

1. In the constructor of our component we create a state object. This will be where we'll store what the user enters in the form.

2. We then connect the state to our two fields in the form by setting `this.state.username` and `this.state.password` as the `value` in our input fields. This means that when the state changes, React will re-render these components with the updated value.

3. But to update the state when the user types something into these fields; we'll call a handle function called `handleChange`. This function grabs the `id` (set as `controlId` for the `<FormGroup>`) of the field being changed and updates it's state with the value the user is typing in. Also, to have access to the `this` keyword inside `handleChange` we store the reference to an anonymous function like so: `handleChange = (event) => { } `.

4. We are setting the `autoFocus` flag for our username field. So that when our form loads, it sets focus to it.

5. We also link up our submit button with our state by using a validate function called `validateForm`. This simply checks if our fields are non-empty, but can easily do something more complicated.

6. Finally, we trigger our callback `handleSubmit` when the form is submitted. For now we are simply suppressing the browsers default behavior on submit but we'll do more here later.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Let's add a couple of styles to this in the file `src/containers/Login.css`.

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

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Now we link this container up with the rest of our app by adding the following line to `src/Routes.js` below our `<IndexRoute>`.

``` coffee
<Route path="login" component={Login} />
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And include our component in the header.

``` javascript
import Login from './containers/Login';
```

Now if we switch to our browser and navigate to the login page we should see our newly created form.

![Login page added screenshot]({{ site.url }}/assets/login-page-added.png)

Next, let's connect our login form to our AWS Cognito setup.
