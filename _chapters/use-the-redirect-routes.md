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

{%change%} First import them in the header of `src/Routes.js`.

``` javascript
import AuthenticatedRoute from "./components/AuthenticatedRoute";
import UnauthenticatedRoute from "./components/UnauthenticatedRoute";
```

Next, we simply switch to our new redirect routes.

So the following routes in `src/Routes.js` would be affected.

``` jsx
<Route exact path="/login">
  <Login />
</Route>
<Route exact path="/signup">
  <Signup />
</Route>
<Route exact path="/settings">
  <Settings />
</Route>
<Route exact path="/notes/new">
  <NewNote />
</Route>
<Route exact path="/notes/:id">
  <Notes />
</Route>
```

{%change%} They should now look like so:

``` jsx
<UnauthenticatedRoute exact path="/login">
  <Login />
</UnauthenticatedRoute>
<UnauthenticatedRoute exact path="/signup">
  <Signup />
</UnauthenticatedRoute>
<AuthenticatedRoute exact path="/settings">
  <Settings />
</AuthenticatedRoute>
<AuthenticatedRoute exact path="/notes/new">
  <NewNote />
</AuthenticatedRoute>
<AuthenticatedRoute exact path="/notes/:id">
  <Notes />
</AuthenticatedRoute>
```

And now if we tried to load a note page while not logged in, we would be redirected to the login page with a reference to the note page.

![Note page redirected to login screenshot](/assets/note-page-redirected-to-login.png)

Next, we are going to use the reference to redirect to the note page after we login.
