---
layout: post
title: Use the Redirect Routes
date: 2017-02-03 00:00:00
lang: en
redirect_from: /chapters/use-the-hoc-in-the-routes.html
description: In our React.js app we can use the AuthenticatedRoute and UnauthenticatedRoute in place of the Routes that we want secured. We’ll do this inside React Router v4’s Switch component.
context: true
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
<AppliedRoute path="/login" exact component={Login} props={childProps} />
<AppliedRoute path="/signup" exact component={Signup} props={childProps} />
<AppliedRoute path="/notes/new" exact component={NewNote} props={childProps} />
<AppliedRoute path="/notes/:id" exact component={Notes} props={childProps} />
```

<img class="code-marker" src="/assets/s.png" />They should now look like so:

``` coffee
<UnauthenticatedRoute path="/login" exact component={Login} props={childProps} />
<UnauthenticatedRoute path="/signup" exact component={Signup} props={childProps} />
<AuthenticatedRoute path="/notes/new" exact component={NewNote} props={childProps} />
<AuthenticatedRoute path="/notes/:id" exact component={Notes} props={childProps} />
```

And now if we tried to load a note page while not logged in, we would be redirected to the login page with a reference to the note page.

![Note page redirected to login screenshot](/assets/note-page-redirected-to-login.png)

Next, we are going to use the reference to redirect to the note page after we login.
