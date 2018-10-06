---
layout: post
title: Handle Routes with React Router
date: 2017-01-10 00:00:00
description: Create React App does not ship with a way to set up routes in your app. To do so, we are going to use React Router. The latest version of React Router, React Router v4 embraces the composable nature of React’s components and makes it easy to work with routes in our single page app.
context: true
comments_id: handle-routes-with-react-router/116
---

Create React App sets a lot of things up by default but it does not come with a built-in way to handle routes. And since we are building a single page app, we are going to use [React Router](https://reacttraining.com/react-router/) to handle them for us.


Let's start by installing React Router. We are going to be using the React Router v4, the newest version of React Router. React Router v4 can be used on the web and in native. So let's install the one for the web.

### Installing React Router v4

<img class="code-marker" src="/assets/s.png" />Run the following command in your working directory.

``` bash
$ npm install react-router-dom --save
```

This installs the NPM package and adds the dependency to your `package.json`.

### Setting up React Router

Even though we don't have any routes set up in our app, we can get the basic structure up and running. Our app currently runs from the `App` component in `src/App.js`. We are going to be using this component as the container for our entire app. To do that we'll encapsulate our `App` component within a `Router`.

<img class="code-marker" src="/assets/s.png" />Replace the following code in `src/index.js`:

``` coffee
ReactDOM.render(<App />, document.getElementById('root'));
```

<img class="code-marker" src="/assets/s.png" />With this:

``` coffee
ReactDOM.render(
  <Router>
    <App />
  </Router>,
  document.getElementById("root")
);
```

<img class="code-marker" src="/assets/s.png" />And import this in the header of `src/index.js`.

``` coffee
import { BrowserRouter as Router } from "react-router-dom";
```

We've made two small changes here.

1. Use `BrowserRouter` as our router. This uses the browser's [History](https://developer.mozilla.org/en-US/docs/Web/API/History) API to create real URLs.
2. Use the `Router` to render our `App` component. This will allow us to create the routes we need inside our `App` component.

Now if you head over to your browser, your app should load just like before. The only difference being that we are using React Router to serve out our pages.

Next we are going to look into how to organize the different pages of our app.
