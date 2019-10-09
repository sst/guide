---
layout: post
title: Redirect on Login and Logout
date: 2017-01-17 00:00:00
lang: en
ref: redirect-on-login-and-logout
description: To ensure that the user is redirected after logging in and logging out of our React.js app, we are going to use the withRouter higher-order component from React Router v4. And we’ll use the history.push method to navigate the app.
context: true
comments_id: redirect-on-login-and-logout/154
---

To complete the login flow we are going to need to do two more things.

1. Redirect the user to the homepage after they login.
2. And redirect them back to the login page after they logout.

We are going to use the `history.push` method that comes with React Router v4.

### Redirect to Home on Login

Since our `Login` component is rendered using a `Route`, it adds the router props to it. So we can redirect using the `this.props.history.push` method.

``` javascript
props.history.push("/");
```

<img class="code-marker" src="/assets/s.png" />Update the `handleSubmit` method in `src/containers/Login.js` to look like this:

``` javascript
async function handleSubmit(event) {
  event.preventDefault();

  try {
    await Auth.signIn(email, password);
    props.userHasAuthenticated(true);
    props.history.push("/");
  } catch (e) {
    alert(e.message);
  }
}
```

Now if you head over to your browser and try logging in, you should be redirected to the homepage after you've been logged in.

![React Router v4 redirect home after login screenshot](/assets/redirect-home-after-login.png)

### Redirect to Login After Logout

Now we'll do something very similar for the logout process. However, the `App` component does not have access to the router props directly since it is not rendered inside a `Route` component. To be able to use the router props in our `App` component we will need to use the `withRouter` [Higher-Order Component](https://facebook.github.io/react/docs/higher-order-components.html) (or HOC). You can read more about the `withRouter` HOC [here](https://reacttraining.com/react-router/web/api/withRouter).

To use this HOC, we'll change the way we export our App component.

<img class="code-marker" src="/assets/s.png" />Replace the following line in `src/App.js`.

``` coffee
export default App;
```

<img class="code-marker" src="/assets/s.png" />With this.

``` coffee
export default withRouter(App);
```

<img class="code-marker" src="/assets/s.png" />And import `withRouter` by replacing the `import { Link }` line in the header of `src/App.js` with this:

``` coffee
import { Link, withRouter } from "react-router-dom";
```

<img class="code-marker" src="/assets/s.png" />Add the following to the bottom of the `handleLogout` function in our `src/App.js`.

``` coffee
props.history.push("/login");
```

So our `handleLogout` method should now look like this.

``` javascript
async function handleLogout() {
  await Auth.signOut();

  userHasAuthenticated(false);

  props.history.push("/login");
}
```

This redirects us back to the login page once the user logs out.

Now if you switch over to your browser and try logging out, you should be redirected to the login page.

You might have noticed while testing this flow that since the login call has a bit of a delay, we might need to give some feedback to the user that the login call is in progress. Let's do that next.
