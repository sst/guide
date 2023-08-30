---
layout: post
title: Handle Routes with React Router
date: 2017-01-10 00:00:00
lang: en
ref: handle-routes-with-react-router
description: To handle routes in our React app we are going to use React Router.
comments_id: handle-routes-with-react-router/116
---

Since we are building a single page app, we are going to use [React Router](https://reactrouter.com/en/main) to handle the routes on the client side for us.

React Router allows us to specify a route like: `/login`. And specify a React Component that should be loaded when a user goes to that page.

Let's start by installing React Router.

### Installing React Router

{%change%} Run the following command **in the `packages/frontend/` directory**.

```bash
$ pnpm add --save react-router-dom
```

This installs the package and adds the dependency to  `package.json` in your React app.

### Setting up React Router

Even though we don't have any routes set up in our app, we can get the basic structure up and running. Our app currently runs from the `App` component in `src/App.tsx`. We are going to be using this component as the container for our entire app. To do that we'll encapsulate our `App` component within a `Router`.

{%change%} Replace the following in `src/main.tsx`:

```tsx
<React.StrictMode>
  <App />
</React.StrictMode>
```

{%change%} With this:

```tsx
<React.StrictMode>
  <Router>
    <App />
  </Router>
</React.StrictMode>
```

{%change%} And import this in the header of `src/main.tsx`.

```tsx
import { BrowserRouter as Router } from "react-router-dom";
```

We've made two small changes here.

1. Use `BrowserRouter` as our router. This uses the browser's [History](https://developer.mozilla.org/en-US/docs/Web/API/History) API to create real URLs.
2. Use the `Router` to render our `App` component. This will allow us to create the routes we need inside our `App` component.

Now if you head over to your browser, your app should load just like before. The only difference being that we are using React Router to serve out our pages.

Next we are going to look into how to organize the different pages of our app.
