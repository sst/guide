---
layout: post
title: Clear the Session on Logout
date: 2017-01-16 00:00:00
lang: en
ref: clear-the-session-on-logout
description: We need to make sure to clear the logged in user's Amazon Cognito session in our React.js app when the user logs out. We can do this using AWS Amplify's Auth.signOut() method.
comments_id: clear-the-session-on-logout/70
---

Currently we are only removing the user session from our app's state. But when we refresh the page, we load the user session from the browser Local Storage (using Amplify), in effect logging them back in.

AWS Amplify has a `Auth.signOut()` method that helps clear it out.

<img class="code-marker" src="/assets/s.png" />Let's replace the `handleLogout` function in our `src/App.js` with this:

``` javascript
async function handleLogout() {
  await Auth.signOut();

  userHasAuthenticated(false);
}
```

Now if you head over to your browser, logout and then refresh the page; you should be logged out completely.

If you try out the entire login flow from the beginning you'll notice that, we continue to stay on the login page throughout the entire process. Next, we'll look at redirecting the page after we login and logout to make the flow make more sense.
