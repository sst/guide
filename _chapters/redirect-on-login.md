---
layout: post
title: Redirect on Login
date: 2017-02-04 00:00:00
---

Our secured pages redirect to the login page when the user is not logged in, with a referral to the originating page. To redirect back after they login, we need to add a couple of things to our `Login` container.

Let's start by adding a method to read the `redirect` URL from the querystring.

{% include code-marker.html %} Add the following method to your `src/containers/Login.js` below the `constructor` method.

``` javascript
querystring(name, url = window.location.href) {
  name = name.replace(/[\[\]]/g, "\\$&");

  const regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)", "i");
  const results = regex.exec(url);

  if ( ! results) { return null; }
  if ( ! results[2]) { return ''; }

  return decodeURIComponent(results[2].replace(/\+/g, " "));
}
```

This method takes the querystring param we want to read and returns it.

Now let's update our `handleSubmit` method to redirect to the new `redirect` URL upon login.

{% include code-marker.html %} Replace our current `handleSubmit` with the following.

``` javascript
handleSubmit = async (event) => {
  event.preventDefault();

  this.setState({ isLoading: true });

  try {
    const userToken = await this.login(this.state.username, this.state.password);
    const redirect = this.querystring('redirect');

    this.props.updateUserToken(userToken);
    this.props.router.push(redirect === '' || redirect === null
      ? '/'
      : redirect);
  }
  catch(e) {
    alert(e);
    this.setState({ isLoading: false });
  }
}
```

Now our login page should redirect after we login.

And that's it! Our app is ready to go live. Let's look at how we are going to deploy it using our serverless setup.
