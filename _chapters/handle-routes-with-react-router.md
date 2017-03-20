---
layout: post
title: Handle Routes with React Router
date: 2017-01-10 00:00:00
description: Tutorial on how to handle routes in your React.js app using React Router v4.
code: frontend
---

Create React App sets a lot of things up by default but it does not come with a built-in way to handle routes. And since we are building a single page app, we are going to use [React Router](https://reacttraining.com/react-router/) to handle them for us.


Let's start by installing React Router. React Router can be used on the web and in native. So let's install the one for the web.

### Installing React Router

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Run the following command in your working directory.

``` bash
$ npm install react-router-dom --save
```

This installs the NPM package and adds the dependency to your `package.json`.

### Setting up the Router

Even though we don't have any routes setup in our app, we can get the basic structure up and running. Our app currently runs from the `App` component in `src/App.js`. We are going to be using this component as the container for our entire app. To do that we'll encapsulate our `App` component within a `Router`.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Replace code in `src/index.js` with the following.

``` coffee
import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter as Router } from 'react-router-dom';
import App from './App';
import './index.css';

ReactDOM.render(
  <Router>
    <App />
  </Router>,
  document.getElementById('root')
);
```

We've made two small changes here.

1. Use `BrowserRouter` as our Router. This uses the browser's [History](https://developer.mozilla.org/en-US/docs/Web/API/History) API to create real URLs.
2. Use the `Router` to render our `App` component. This will alow us to create the routes we need inside our `App` component.

Now if you head over to your browser, your app should load just like before. The only difference being that we are using React Router to serve out our pages.

Next we are going to look into how to organize the different pages of our app.
