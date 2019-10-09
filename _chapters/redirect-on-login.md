---
layout: post
title: Redirect on Login
date: 2017-02-04 00:00:00
lang: en
description: To make sure that our React.js redirects a user to the right page after they login, we are going to use the React Router v4 Redirect component.
code: backend
comments_id: redirect-on-login/24
ref: redirect-on-login
---

Our secured pages redirect to the login page when the user is not logged in, with a referral to the originating page. To redirect back after they login, we need to do a couple of more things. Currently, our `Login` component does the redirecting after the user logs in. We are going to move this to the newly created `UnauthenticatedRoute` component.

Let's start by adding a method to read the `redirect` URL from the querystring.

<img class="code-marker" src="/assets/s.png" />Add the following method to your `src/components/UnauthenticatedRoute.js` below the imports.

``` coffee
function querystring(name, url = window.location.href) {
  name = name.replace(/[[]]/g, "\\$&");

  const regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)", "i");
  const results = regex.exec(url);

  if (!results) {
    return null;
  }
  if (!results[2]) {
    return "";
  }

  return decodeURIComponent(results[2].replace(/\+/g, " "));
}
```

This method takes the querystring param we want to read and returns it.

Now let's update our component to use this parameter when it redirects.

<img class="code-marker" src="/assets/s.png" />Replace our current `UnauthenticatedRoute` function component with the following.

``` coffee
export default function UnauthenticatedRoute({ component: C, appProps, ...rest }) {
  const redirect = querystring("redirect");
  return (
    <Route
      {...rest}
      render={props =>
        !appProps.isAuthenticated
          ? <C {...props} {...appProps} />
          : <Redirect
              to={redirect === "" || redirect === null ? "/" : redirect}
            />}
    />
  );
}
```

<img class="code-marker" src="/assets/s.png" />And remove the following from the `handleSubmit` method in `src/containers/Login.js`.

``` coffee
props.history.push("/");
```

Now our login page should redirect after we login. And that's it! Our app is ready to go live.

### Commit the Changes

<img class="code-marker" src="/assets/s.png" />Let's commit our code so far and push it to GitHub.

``` bash
$ git add .
$ git commit -m "Building our React app"
$ git push
```

Next we'll be looking at how to automate this stack so we can use it for our future projects. You can also take a look at how to add a Login with Facebook option in the [Facebook Login with Cognito using AWS Amplify]({% link _chapters/facebook-login-with-cognito-using-aws-amplify.md %}) chapter. It builds on what we have covered so far.
