---
layout: post
title: Redirect on Login and Logout
date: 2017-01-17 00:00:00
lang: en
ref: redirect-on-login-and-logout
description: To ensure that the user is redirected after logging in and logging out of our React.js app, we are going to use the useHistory React hook from React Router. And we’ll use the history.push method to navigate the app.
comments_id: redirect-on-login-and-logout/154
---

To complete the login flow we are going to need to do two more things.

1. Redirect the user to the homepage after they login.
2. And redirect them back to the login page after they logout.

We are going to use the `useHistory` hook that comes with React Router.

### Redirect to Home on Login

<img class="code-marker" src="/assets/s.png" />First, initialize `useHistory` hook in the beginning of `src/containers/Login.js`.

``` javascript
const history = useHistory();
```

<img class="code-marker" src="/assets/s.png" />Then update the `handleSubmit` method in `src/containers/Login.js` to look like this:

``` javascript
async function handleSubmit(event) {
  event.preventDefault();

  try {
    await Auth.signIn(email, password);
    userHasAuthenticated(true);
    history.push("/");
  } catch (e) {
    alert(e.message);
  }
}
```

<img class="code-marker" src="/assets/s.png" /> Also, import `useHistory` from React Router in the header of `src/containers/Login.js`.

``` javascript
import { useHistory } from "react-router-dom";
```

Now if you head over to your browser and try logging in, you should be redirected to the homepage after you've been logged in.

![React Router v4 redirect home after login screenshot](/assets/redirect-home-after-login.png)

### Redirect to Login After Logout

Now we'll do something very similar for the logout process. 

<img class="code-marker" src="/assets/s.png" />Add the `useHistory` hook in the beginning of `App` component.

``` javascript
const history = useHistory();
```

<img class="code-marker" src="/assets/s.png" />Import `useHistory` by replacing the `import { Link }` line in the header of `src/App.js` with this:

``` coffee
import { Link, useHistory } from "react-router-dom";
```

<img class="code-marker" src="/assets/s.png" />Add the following to the bottom of the `handleLogout` function in our `src/App.js`.

``` coffee
history.push("/login");
```

So our `handleLogout` function should now look like this.

``` javascript
async function handleLogout() {
  await Auth.signOut();

  userHasAuthenticated(false);

  history.push("/login");
}
```

This redirects us back to the login page once the user logs out.

Now if you switch over to your browser and try logging out, you should be redirected to the login page.

You might have noticed while testing this flow that since the login call has a bit of a delay, we might need to give some feedback to the user that the login call is in progress. Also, we are not doing a whole lot with the errors that the `Auth` package might throw. Let's look at those next.
