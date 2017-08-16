---
layout: post
title: Redirect on Login and Logout
date: 2017-01-17 00:00:00
description: To ensure that the user is redirected after logging in and logging out of our React.js app, we are going to use the withRouter higher-order component from React Router v4. And we’ll use the history.push method to navigate the app.
context: frontend
code: frontend
comments_id: 42
---

To complete the login flow we are going to need to do two more things.

1. Redirect the user to the homepage after they login.
2. And redirect them back to the login page after they logout.

We are going to use the `history.push` method that comes with React Router v4.

### Redirect to Home on Login

Since our `Login` component is rendered using a `Route`, it adds the router props to it. So we can redirect using the `this.props.history.push` method.

``` javascript
this.props.history.push('/');
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Update the `handleSubmit` method in `src/containers/Login.js` to look like this:

``` javascript
handleSubmit = async event => {
  event.preventDefault();

  try {
    await this.login(this.state.email, this.state.password);
    this.props.userHasAuthenticated(true);
    this.props.history.push('/');
  }
  catch(e) {
    alert(e);
  }
}
```

Now if you head over to your browser and try logging in, you should be redirected to the homepage after you've been logged in.

![React Router v4 redirect home after login screenshot]({{ site.url }}/assets/redirect-home-after-login.png)

### Redirect to Login After Logout

Now we'll do something very similar for the logout process. However, the `App` component does not have access to the router props directly since it is not rendered inside a `Route` component. To be able to use the router props in our `App` component we will need to use the `withRouter` [Higher-Order Component](https://facebook.github.io/react/docs/higher-order-components.html) (or HOC). You can read more about the `withRouter` HOC [here](https://reacttraining.com/react-router/web/api/withRouter).

To use this HOC, we'll change the way we export our App component.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace the following line in `src/App.js`.

``` coffee
export default App;
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />With this.


``` coffee
export default withRouter(App);
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to the bottom of the `handleLogout` method in our `src/App.js`.

``` coffee
this.props.history.push('/login');
```

So our `handleLogout` method should now look like this.

``` coffee
handleLogout = event => {
  signOutUser();

  this.userHasAuthenticated(false);

  this.props.history.push('/login');
}
```

This redirects us back to the login page once the user logs out.

Now if you switch over to your browser and try logging out, you should be redirected to the login page.

You might have noticed while testing this flow that since the login call has a bit of a delay, we might need to give some feedback to the user that the login call is in progress. Let's do that next.
