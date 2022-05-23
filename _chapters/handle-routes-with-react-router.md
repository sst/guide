---
layout: post
title: Handle Routes with React Router
date: 2017-01-10 00:00:00
lang: en
ref: handle-routes-with-react-router
description: Create React App does not ship with a way to set up routes in your app. To do so, we are going to use React Router. The latest version of React Router, React Router v6 embraces the composable nature of React’s components and makes it easy to work with routes in our single page app.
comments_id: handle-routes-with-react-router/116
---

Create React App sets a lot of things up by default but it does not come with a built-in way to handle routes. And since we are building a single page app, we are going to use [React Router](https://reacttraining.com/react-router/) to handle them for us.

React Router allows us to specify a route like: `/login`. And specify a React Component that should be loaded when a user goes to that page.

Let's start by installing React Router.

### Installing React Router

{%change%} Run the following command in the `frontend/` directory and **not** in your project root.

```bash
$ npm install react-router-dom
```

This installs the NPM package and adds the dependency to the `package.json` of your React app.

### Setting up React Router

Even though we don't have any routes set up in our app, we can get the basic structure up and running. Our app currently runs from the `App` component in `src/App.js`. We are going to be using this component as the container for our entire app. To do that we'll encapsulate our `App` component within a `Router`.

{%change%} Replace the following code in `src/index.js`:

```jsx
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

{%change%} With this:

```jsx
root.render(
  <React.StrictMode>
    <Router>
      <App />
    </Router>
  </React.StrictMode>
);
```

{%change%} And import this in the header of `src/index.js`.

```jsx
import { BrowserRouter as Router } from "react-router-dom";
```

We've made two small changes here.

1. Use `BrowserRouter` as our router. This uses the browser's [History](https://developer.mozilla.org/en-US/docs/Web/API/History) API to create real URLs.
2. Use the `Router` to render our `App` component. This will allow us to create the routes we need inside our `App` component.

Now if you head over to your browser, your app should load just like before. The only difference being that we are using React Router to serve out our pages.

Next we are going to look into how to organize the different pages of our app.
