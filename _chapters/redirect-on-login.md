---
layout: post
title: Redirect on Login
date: 2017-02-04 00:00:00
lang: en
description: To make sure that our React.js redirects a user to the right page after they login, we are going to use the React Router useNavigate hook.
comments_id: redirect-on-login/24
ref: redirect-on-login
---

Our secured pages redirect to the login page when the user is not logged in, with a referral to the originating page. To redirect back after they login, we need to do a couple of more things. Currently, our `Login` component does the redirecting after the user logs in. We are going to move this to the newly created `UnauthenticatedRoute` component.

Let's start by adding a method to read the `redirect` URL from the querystring.

{%change%} Add the following method to your `src/components/UnauthenticatedRoute.js` below the imports.

```jsx
function querystring(name, url = window.location.href) {
  const parsedName = name.replace(/[[]]/g, "\\$&");
  const regex = new RegExp(`[?&]${parsedName}(=([^&#]*)|&|#|$)`, "i");
  const results = regex.exec(url);

  if (!results || !results[2]) {
    return false;
  }

  return decodeURIComponent(results[2].replace(/\+/g, " "));
}
```

This method takes the querystring param we want to read and returns it.

Now let's update our component to use this parameter when it redirects.

{%change%} Replace our current `UnauthenticatedRoute` function component with the following.

```jsx
export default function UnauthenticatedRoute(props) {
  const { isAuthenticated } = useAppContext();
  const { children } = props;
  const redirect = querystring("redirect");

  if (isAuthenticated) {
    return <Navigate to={redirect || "/"} />;
  }

  return cloneElement(children, props);
}
```

{%change%} And remove the following from the `handleSubmit` method in `src/containers/Login.js`.

```jsx
nav("/");
```

{%change%} Also, remove the hook declaration.

```jsx
const nav = useNavigate();
```

{%change%} Finally, remove the import.

```jsx
import { useNavigate } from "react-router-dom";
```

Now our login page should redirect after we login.

### Commit the Changes

{%change%} Let's commit our code so far and push it to GitHub.

```bash
$ git add .
$ git commit -m "Building our React app"
$ git push
```

And that's it! Our app is ready to go live.

Next we'll be deploying our serverless app to production. And we'll do it using our own domain!
