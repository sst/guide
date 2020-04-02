---
layout: post
title: Use the Redirect Routes
date: 2017-02-03 00:00:00
lang: en
redirect_from: /chapters/use-the-hoc-in-the-routes.html
description: In our React.js app we can use the AuthenticatedRoute and UnauthenticatedRoute in place of the Routes that we want secured. We’ll do this inside React Router v4’s Switch component.
comments_id: use-the-redirect-routes/152
ref: use-the-redirect-routes
---

Now that we created the `AuthenticatedRoute` and `UnauthenticatedRoute` in the last chapter, let's use them on the containers we want to secure.

<img class="code-marker" src="/assets/s.png" />First import them in the header of `src/Routes.js`.

``` javascript
import AuthenticatedRoute from "./components/AuthenticatedRoute";
import UnauthenticatedRoute from "./components/UnauthenticatedRoute";
```

Next, we simply switch to our new redirect routes.

So the following routes in `src/Routes.js` would be affected.

``` coffee
<Route path="/login" exact>
  <Login {...appProps} />
</Route>
<Route path="/signup" exact>
  <Signup {...appProps} />
</Route>
<Route path="/settings" exact>
  <Settings />
</Route>
<Route path="/notes/new" exact>
  <NewNote />
</Route>
<Route path="/notes/:id" exact>
  <Notes />
</Route>
```

<img class="code-marker" src="/assets/s.png" />They should now look like so:

``` coffee
<UnauthenticatedRoute path="/login" exact appProps={appProps}>
  <Login {...appProps} />
</UnauthenticatedRoute>
<UnauthenticatedRoute path="/signup" exact appProps={appProps}>
  <Signup {...appProps} />
</UnauthenticatedRoute>
<AuthenticatedRoute path="/settings" exact appProps={appProps}>
  <Settings />
</AuthenticatedRoute>
<AuthenticatedRoute path="/notes/new" exact appProps={appProps}>
  <NewNote />
</AuthenticatedRoute>
<AuthenticatedRoute path="/notes/:id" exact appProps={appProps}>
  <Notes />
</AuthenticatedRoute>
```

And now if we tried to load a note page while not logged in, we would be redirected to the login page with a reference to the note page.

![Note page redirected to login screenshot](/assets/note-page-redirected-to-login.png)

Next, we are going to use the reference to redirect to the note page after we login.
