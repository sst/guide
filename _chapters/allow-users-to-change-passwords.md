---
layout: post
title: Allow Users to Change Passwords
description: Use the AWS Amplify Auth.changePassword method to support change password functionality in our Serverless React app. This triggers Cognito to help our users change their password.
date: 2018-04-15 00:00:00
context: true
code: user-management
comments_id: allow-users-to-change-passwords/507
---

For our [Serverless notes app](https://demo.serverless-stack.com), we want to allow our users to change their password. Recall that we are using Cognito to manage our users and AWS Amplify in our React app. In this chapter we will look at how to do that.

For reference, we are using a forked version of the notes app with:

- A separate GitHub repository: [**{{ site.frontend_user_mgmt_github_repo }}**]({{ site.frontend_user_mgmt_github_repo }})
- And it can be accessed through: [**https://demo-user-mgmt.serverless-stack.com**](https://demo-user-mgmt.serverless-stack.com)

Let's start by creating a settings page that our users can use to change their password.

### Add a Settings Page

<img class="code-marker" src="/assets/s.png" />Add the following to `src/containers/Settings.js`.

``` coffee
import React, { Component } from "react";
import { LinkContainer } from "react-router-bootstrap";
import LoaderButton from "../components/LoaderButton";
import "./Settings.css";

export default class Settings extends Component {
  constructor(props) {
    super(props);

    this.state = {
    };
  }

  render() {
    return (
      <div className="Settings">
        <LinkContainer to="/settings/email">
          <LoaderButton
            block
            bsSize="large"
            text="Change Email"
          />
        </LinkContainer>
        <LinkContainer to="/settings/password">
          <LoaderButton
            block
            bsSize="large"
            text="Change Password"
          />
        </LinkContainer>
      </div>
    );
  }
}
```

All this does is add two links to a page that allows our users to change their password and email.

<img class="code-marker" src="/assets/s.png" />Let's also add a couple of styles for this page.

``` css
@media all and (min-width: 480px) {
  .Settings {
    padding: 60px 0;
    margin: 0 auto;
    max-width: 320px;
  }
}
.Settings .LoaderButton:last-child {
  margin-top: 15px;
}
```

<img class="code-marker" src="/assets/s.png" />Add a link to this settings page to the navbar of our app by changing `src/App.js`.

``` coffee
<Navbar fluid collapseOnSelect>
  <Navbar.Header>
    <Navbar.Brand>
      <Link to="/">Scratch</Link>
    </Navbar.Brand>
    <Navbar.Toggle />
  </Navbar.Header>
  <Navbar.Collapse>
    <Nav pullRight>
      {this.state.isAuthenticated
        ? <Fragment>
            <LinkContainer to="/settings">
              <NavItem>Settings</NavItem>
            </LinkContainer>
            <NavItem onClick={this.handleLogout}>Logout</NavItem>
          </Fragment>
        : <Fragment>
            <LinkContainer to="/signup">
              <NavItem>Signup</NavItem>
            </LinkContainer>
            <LinkContainer to="/login">
              <NavItem>Login</NavItem>
            </LinkContainer>
          </Fragment>
      }
    </Nav>
  </Navbar.Collapse>
</Navbar>
```

<img class="code-marker" src="/assets/s.png" />Also, add the route to our `src/Routes.js`.

``` html
<AuthenticatedRoute
  path="/settings"
  exact
  component={Settings}
  props={childProps}
/>
```

<img class="code-marker" src="/assets/s.png" />And don't forget to import it.

``` coffee
import Settings from "./containers/Settings";
```

This should give us a settings page that our users can get to from the app navbar.

![Settings page screenshot](/assets/user-management/settings-page.png)

### Change Password Form

Now let's create the form that allows our users to change their password. 

<img class="code-marker" src="/assets/s.png" />Add the following to `src/containers/ChangePassword.js`.

``` coffee
import React, { Component } from "react";
import { Auth } from "aws-amplify";
import { FormGroup, FormControl, ControlLabel } from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
import "./ChangePassword.css";

export default class ChangePassword extends Component {
  constructor(props) {
    super(props);

    this.state = {
      password: "",
      oldPassword: "",
      isChanging: false,
      confirmPassword: ""
    };
  }

  validateForm() {
    return (
      this.state.oldPassword.length > 0 &&
      this.state.password.length > 0 &&
      this.state.password === this.state.confirmPassword
    );
  }

  handleChange = event => {
    this.setState({
      [event.target.id]: event.target.value
    });
  };

  handleChangeClick = async event => {
    event.preventDefault();

    this.setState({ isChanging: true });

    try {
      const currentUser = await Auth.currentAuthenticatedUser();
      await Auth.changePassword(
        currentUser,
        this.state.oldPassword,
        this.state.password
      );

      this.props.history.push("/settings");
    } catch (e) {
      alert(e.message);
      this.setState({ isChanging: false });
    }
  };

  render() {
    return (
      <div className="ChangePassword">
        <form onSubmit={this.handleChangeClick}>
          <FormGroup bsSize="large" controlId="oldPassword">
            <ControlLabel>Old Password</ControlLabel>
            <FormControl
              type="password"
              onChange={this.handleChange}
              value={this.state.oldPassword}
            />
          </FormGroup>
          <hr />
          <FormGroup bsSize="large" controlId="password">
            <ControlLabel>New Password</ControlLabel>
            <FormControl
              type="password"
              value={this.state.password}
              onChange={this.handleChange}
            />
          </FormGroup>
          <FormGroup bsSize="large" controlId="confirmPassword">
            <ControlLabel>Confirm Password</ControlLabel>
            <FormControl
              type="password"
              onChange={this.handleChange}
              value={this.state.confirmPassword}
            />
          </FormGroup>
          <LoaderButton
            block
            type="submit"
            bsSize="large"
            text="Change Password"
            loadingText="Changing…"
            disabled={!this.validateForm()}
            isLoading={this.state.isChanging}
          />
        </form>
      </div>
    );
  }
}
```

Most of this should be very straightforward. The key part of the flow here is that we ask the user for their current password along with their new password. Once they enter it, we can call the following:

``` coffee
const currentUser = await Auth.currentAuthenticatedUser();
await Auth.changePassword(
  currentUser,
  this.state.oldPassword,
  this.state.password
);
```

The above snippet uses the `Auth` module from Amplify to get the current user. And then uses that to change their password by passing in the old and new password. Once the `Auth.changePassword` method completes, we redirect the user to the settings page.

<img class="code-marker" src="/assets/s.png" />Let's also add a couple of styles.

``` css
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

<img class="code-marker" src="/assets/s.png" />Let's add our new page to `src/Routes.js`.

``` html
<AuthenticatedRoute
  path="/settings/password"
  exact
  component={ChangePassword}
  props={childProps}
/>
```

<img class="code-marker" src="/assets/s.png" />And import it.

``` coffee
import ChangePassword from "./containers/ChangePassword";
```

That should do it. The `/settings/password` page should allow us to change our password.

![Change password page screenshot](/assets/user-management/change-password-page.png)

Next, let's look at how to implement a change email form for our users.
