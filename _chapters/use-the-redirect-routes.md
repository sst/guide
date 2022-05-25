---
layout: post
title: Use the Redirect Routes
date: 2017-02-03 00:00:00
lang: en
redirect_from: /chapters/use-the-hoc-in-the-routes.html
description: In our React.js app we can use the AuthenticatedRoute and UnauthenticatedRoute in place of the Routes that we want secured. We’ll do this inside React Router v6’s Routes component.
comments_id: use-the-redirect-routes/152
ref: use-the-redirect-routes
---

Now that we created the `AuthenticatedRoute` and `UnauthenticatedRoute` in the last chapter, let's use them on the containers we want to secure.

{%change%} First import them in the header of `src/Routes.js`.

```js
import AuthenticatedRoute from "./components/AuthenticatedRoute";
import UnauthenticatedRoute from "./components/UnauthenticatedRoute";
```

Next, we simply switch to our new redirect routes.

So the following routes in `src/Routes.js` would be affected.

```jsx
<Route path="/login" element={<Login />} />
<Route path="/signup" element={<Signup />} />
<Route path="/settings" element={<Settings />} />
<Route path="/notes/new" element={<NewNote />} />
<Route path="/notes/:id" element={<Notes />} />
```

{%change%} They should now look like so:

```jsx
<Route
  path="/login"
  element={
    <UnauthenticatedRoute>
      <Login />
    </UnauthenticatedRoute>
  }
/>
<Route
  path="/signup"
  element={
    <UnauthenticatedRoute>
      <Signup />
    </UnauthenticatedRoute>
  }
/>
<Route
  path="/settings"
  element={
    <AuthenticatedRoute>
      <Settings />
    </AuthenticatedRoute>
  }
/>
<Route
  path="/notes/new"
  element={
    <AuthenticatedRoute>
      <NewNote />
    </AuthenticatedRoute>
  }
/>

<Route
  path="/notes/:id"
  element={
    <AuthenticatedRoute>
      <Notes />
    </AuthenticatedRoute>
  }
/>
```

And now if we tried to load a note page while not logged in, we would be redirected to the login page with a reference to the note page.

![Note page redirected to login screenshot](/assets/note-page-redirected-to-login.png)

Next, we are going to use the reference to redirect to the note page after we login.
