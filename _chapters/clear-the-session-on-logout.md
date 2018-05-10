---
layout: post
title: Clear the Session on Logout
date: 2017-01-16 00:00:00
description: We need to make sure to clear the logged in user's Amazon Cognito session in our React.js app when the user logs out. We can do this using AWS Amplify's Auth.signOut() method.
context: true
comments_id: clear-the-session-on-logout/70
---

Currently we are only removing the user session from our app's state. But when we refresh the page, we load the user session from the browser Local Storage (using Amplify), in effect logging them back in.

AWS Amplify has a `Auth.signOut()` method that helps clear it out.

<img class="code-marker" src="/assets/s.png" />Let's replace the `handleLogout` method in our `src/App.js` with this:

``` javascript
handleLogout = async event => {
  await Auth.signOut();

  this.userHasAuthenticated(false);
}
```

Now if you head over to your browser, logout and then refresh the page; you should be logged out completely.

If you try out the entire login flow from the beginning you'll notice that, we continue to stay on the login page through out the entire process. Next, we'll look at redirecting the page after we login and logout to make the flow make more sense.
