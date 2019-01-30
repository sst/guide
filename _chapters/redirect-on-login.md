---
layout: post
title: Redirect on Login
date: 2017-02-04 00:00:00
description: To make sure that our React.js redirects a user to the right page after they login, we are going to use the React Router v4 Redirect component.
context: true
comments_id: redirect-on-login/24
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

<img class="code-marker" src="/assets/s.png" />Replace our current `export default ({ component: C, props: cProps, ...rest }) => {` method with the following.

``` coffee
export default ({ component: C, props: cProps, ...rest }) => {
  const redirect = querystring("redirect");
  return (
    <Route
      {...rest}
      render={props =>
        !cProps.isAuthenticated
          ? <C {...props} {...cProps} />
          : <Redirect
              to={redirect === "" || redirect === null ? "/" : redirect}
            />}
    />
  );
};
```

<img class="code-marker" src="/assets/s.png" />And remove the following from the `handleSubmit` method in `src/containers/Login.js`.

``` coffee
this.props.history.push("/");
```

Now our login page should redirect after we login.

And that's it! Our app is ready to go live. Let's look at how we are going to deploy it using our serverless setup.
