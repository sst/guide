---
layout: post
title: Redirect on Login and Logout
date: 2017-01-17 00:00:00
lang: en
ref: redirect-on-login-and-logout
description: To ensure that the user is redirected after logging in and logging out of our React.js app, we are going to use the useNavigate React hook from React Router. And we’ll use the nav.push method to navigate the app.
comments_id: redirect-on-login-and-logout/154
---

To complete the login flow we are going to need to do two more things.

1. Redirect the user to the homepage after they login.
2. And redirect them back to the login page after they logout.

We are going to use the `useNavigate` hook that comes with React Router. This will allow us to use the browser's [History API](https://developer.mozilla.org/en-US/docs/Web/API/History).

### Redirect to Home on Login

{%change%} First, initialize `useNavigate` hook in the beginning of `src/containers/Login.js`.

```js
const nav = useNavigate();
```

Make sure to add it below the `export default function Login() {` line.

{%change%} Then update the `handleSubmit` method in `src/containers/Login.js` to look like this:

```js
async function handleSubmit(event) {
  event.preventDefault();

  try {
    await Auth.signIn(email, password);
    userHasAuthenticated(true);
    nav("/");
  } catch (e) {
    alert(e.message);
  }
}
```

{%change%} Also, import `useNavigate` from React Router in the header of `src/containers/Login.js`.

```js
import { useNavigate } from "react-router-dom";
```

Now if you head over to your browser and try logging in, you should be redirected to the homepage after you've been logged in.

![React Router v6 redirect home after login screenshot](/assets/redirect-home-after-login.png)

### Redirect to Login After Logout

Now we'll do something very similar for the logout process.

{%change%} Add the `useNavigate` hook in the beginning of `App` component.

```js
const nav = useNavigate();
```

{%change%} Import `useNavigate` from React Router in the header of `src/App.js`.

```js
import { useNavigate } from "react-router-dom";
```

{%change%} Add the following to the bottom of the `handleLogout` function in our `src/App.js`.

```jsx
nav("/login");
```

So our `handleLogout` function should now look like this.

```js
async function handleLogout() {
  await Auth.signOut();

  userHasAuthenticated(false);

  nav("/login");
}
```

This redirects us back to the login page once the user logs out.

Now if you switch over to your browser and try logging out, you should be redirected to the login page.

You might have noticed while testing this flow that since the login call has a bit of a delay, we might need to give some feedback to the user that the login call is in progress. Also, we are not doing a whole lot with the errors that the `Auth` package might throw. Let's look at those next.
