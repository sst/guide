---
layout: post
title: Redirect on Login and Logout
date: 2017-01-17 00:00:00
description: To ensure that the user is redirected after logging in and logging out of our React.js app, we are going to use the withRouter higher-order component from React Router v4. And we’ll use the history.push method to navigate the app.
code: frontend
comments_id: 42
---

To complete the login flow we are going to need to do two more things.

1. Redirect the user to the homepage after they login.
2. And redirect them back to the login page after they logout.

We are going to use the `withRouter` HOC and the `this.props.history.push` method that comes with React Router v4.

### Redirect to Home on Login

<img class="code-marker" src="{{ site.url }}/assets/s.png" />To use it in our `src/containers/Login.js`, let's replace the line that exports our component.

``` javascript
export default Login;
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />with the following:

``` javascript
export default withRouter(Login);
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Also, import `withRouter` in the header.

``` javascript
import { withRouter } from 'react-router-dom';
```

This Higher-Order Component adds the `history` prop to our component. Now we can redirect using the `this.props.history.push` method.

``` javascript
this.props.history.push('/');
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Our updated `handleSubmit` method in `src/containers/Login.js` should look like this:

``` javascript
handleSubmit = async (event) => {
  event.preventDefault();

  try {
    const userToken = await this.login(this.state.username, this.state.password);
    this.props.updateUserToken(userToken);
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

Now we'll do something very similar for the logout process. Since we are already using the `withRouter` HOC for our App component, we can go ahead and add the bit that does the redirect.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Add the following to the bottom of the `handleLogout` method in our `src/App.js`.

``` coffee
this.props.history.push('/login');
```

So our `handleLogout` method should now look like this.

``` coffee
handleLogout = (event) => {
  const currentUser = this.getCurrentUser();

  if (currentUser !== null) {
    currentUser.signOut();
  }

  this.updateUserToken(null);

  this.props.history.push('/login');
}
```

This redirects us back to the login page once the user logs out.

Now if you switch over to your browser and try logging out, you should be redirected to the login page.

You might have noticed while testing this flow that since the login call has a bit of a delay, we might need to give some feedback to the user that the login call is in progress. Let's do that next.
