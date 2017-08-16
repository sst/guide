---
layout: post
title: Clear the Session on Logout
date: 2017-01-16 00:00:00
description: We need to make sure to clear the logged in session using the Amazon Cognito JS SDK in our React.js app when the user logs out. We can do this using the signOut method.
context: frontend
code: frontend
comments_id: 41
---

Currently we are only removing the user token from our app's state. But when we refresh the page, we load the user session from the browser Local Storage, in effect logging them back in.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Let's create a `signOutUser` method and add it to our `src/libs/awsLib.js`.

``` coffee
export function signOutUser() {
  const currentUser = getCurrentUser();

  if (currentUser !== null) {
    currentUser.signOut();
  }
}
```

Here we are using the AWS Cognito JS SDK to log the user out by calling `currentUser.signOut()`.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Next we'll include that in our `App` component. Replace the `import { authUser }` line in the header of `src/App.js` with:

``` javascript
import { authUser, signOutUser } from "./libs/awsLib";
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And replace the `handleLogout` method in our `src/App.js` with this:

``` javascript
handleLogout = event => {
  signOutUser();

  this.userHasAuthenticated(false);
}
```

Now if you head over to your browser, logout and then refresh the page; you should be logged out completely.

If you try out the entire login flow from the beginning you'll notice that, we continue to stay on the login page through out the entire process. Next, we'll look at redirecting the page after we login and logout to make the flow makes more sense.
