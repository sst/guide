---
layout: post
title: Create the Signup Form
---

Let's start by creating the signup form that'll get the user's email and password.

### Add the Container

Create a new container at `src/containers/Signup.js` with the following.

{% highlight javascript %}
import React, { Component } from 'react';
import { withRouter } from 'react-router';
import {
  FormGroup,
  FormControl,
  ControlLabel,
} from 'react-bootstrap';
import LoaderButton from '../components/LoaderButton.js';
import './Signup.css';

class Signup extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isLoading: false,
      username: '',
      password: '',
      confirmPassword: '',
      confirmationCode: '',
      newUser: null,
    };
  }

  validateForm() {
    return this.state.username.length > 0
      && this.state.password.length > 0
      && this.state.password === this.state.confirmPassword;
  }

  validateCofirmationForm() {
    return this.state.confirmationCode.length > 0;
  }

  handleChange = (event) => {
    this.setState({
      [event.target.id]: event.target.value
    });
  }

  handleSubmit = async (event) => {
    event.preventDefault();

    this.setState({ isLoading: true });

    this.setState({ newUser: 'test' });

    this.setState({ isLoading: false });
  }

  handleConfirmationSubmit = async (event) => {
    event.preventDefault();

    this.setState({ isLoading: true });
  }

  renderConfirmationForm() {
    const isLoading = this.state.isLoading;
    return (
      <form onSubmit={ ! isLoading ? this.handleConfirmationSubmit : null }>
        <FormGroup controlId="confirmationCode">
          <ControlLabel>Confirmation Code</ControlLabel>
          <FormControl
            type="text"
            value={this.state.confirmationCode}
            onChange={this.handleChange} />
        </FormGroup>
        <LoaderButton
          disabled={ ! this.validateCofirmationForm() }
          type="submit"
          isLoading={isLoading}
          text="Verify"
          loadingText="Verifying…" />
      </form>
    );
  }

  renderForm() {
    const isLoading = this.state.isLoading;
    return (
      <form onSubmit={ ! isLoading ? this.handleSubmit : null }>
        <FormGroup controlId="username">
          <ControlLabel>Email</ControlLabel>
          <FormControl
            type="text"
            value={this.state.username}
            onChange={this.handleChange} />
        </FormGroup>
        <FormGroup controlId="password">
          <ControlLabel>Password</ControlLabel>
          <FormControl
            value={this.state.password}
            onChange={this.handleChange}
            type="password" />
        </FormGroup>
        <FormGroup controlId="confirmPassword">
          <ControlLabel>Confirm Password</ControlLabel>
          <FormControl
            value={this.state.confirmPassword}
            onChange={this.handleChange}
            type="password" />
        </FormGroup>
        <LoaderButton
          disabled={ ! this.validateForm() }
          type="submit"
          isLoading={isLoading}
          text="Signup"
          loadingText="Signing up…" />
      </form>
    );
  }

  render() {
    return (
      <div className="Signup">
        { this.state.newUser === null
          ? this.renderForm()
          : this.renderConfirmationForm() }
      </div>
    );
  }
}

export default withRouter(Signup);
{% endhighlight %}

Most of things we are doing here are fairly straightforward but let's go over them quickly.

1. Since we need to show the user a form to enter the confirmation code, we are conditionally rendering two form based on if we have a user object or not.

2. We are using the `LoaderButton` component that we created earlier for our submit buttons.

3. We are also using the `withRouter` HOC on our Singup component.

4. Since we have two forms we have two validation methods called `validateForm` and `validateCofirmationForm`.

5. For now our `handleSubmit` and `handleConfirmationSubmit` don't do a whole lot besides setting the `isLoading` state and a dummy value for the `newUser` state.

Also, let's add a couple of styles in `src/containers/Signup.css`.

{% highlight css %}
.Signup {
  padding: 60px 0;
}

.Signup form {
  margin: 0 auto;
  max-width: 320px;
}
{% endhighlight %}

### Add the Route

Finally, add our container as a route in `src/Routes.js` below our login route.

{% highlight javascript %}
<Route path="signup" component={Signup} />
{% endhighlight %}

And include our component in the header.

{% highlight javascript %}
import Signup from './containers/Signup';
{% endhighlight %}

Now if we switch to our browser and navigate to the signup page we should see our newly created form. Try filling in the form and ensure that it shows the confirmation code form as well.

![Signup page added screenshot]({{ site.url }}/assets/signup-page-added.png)

Next, let's connect our signup form to AWS Cognito.
