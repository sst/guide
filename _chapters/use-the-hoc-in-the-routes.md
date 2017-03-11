---
layout: post
title: Use the HOC in the Routes
date: 2017-02-03 00:00:00
description: Tutorial on how to add a Higher-Order Component in your React Router routes for your React.js app.
code: frontend
---

Now that we created the `AuthenticatedComponent` and `UnauthenticatedComponent`, let's use them on the containers we want to secure.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />First import them in the header of `src/Routes.js`.

``` javascript
import requireAuth from './components/AuthenticatedComponent';
import requireUnauth from './components/UnauthenticatedComponent';
```

Next, we simply wrap the components we want secured.

So the following routes in `src/Routes.js` would be affected.

``` coffee
<Route path="login" component={Login} />
<Route path="signup" component={Signup} />
<Route path="notes/new" component={NewNote} />
<Route path="notes/:id" component={Notes} />
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />They should now look like so:

``` coffee
<Route path="login" component={requireUnauth(Login)} />
<Route path="signup" component={requireUnauth(Signup)} />
<Route path="notes/new" component={requireAuth(NewNote)} />
<Route path="notes/:id" component={requireAuth(Notes)} />
```

And now if we tried to load a note page while not logged in, we would be redirected to the login page with a reference to the note page.

![Note page redirected to login screenshot]({{ site.url }}/assets/note-page-redirected-to-login.png)

Next we are going to use the referral to redirect to the note page after we login.
