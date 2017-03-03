---
layout: post
title: Handle Routes with React Router
date: 2017-01-10 00:00:00
code: frontend
---

Create React App sets a lot of things up by default but it does not come with a built-in way to handle routes. And since we are building a single page app, we are going to use [React Router](https://reacttraining.com/react-router/) to handle them for us.

Let's start by installing React Router.

### Installing React Router

{% include code-marker.html %} Run the following command in your working directory.

``` bash
$ npm install react-router --save
```

This installs the NPM package and adds the dependency to your `package.json`.

### Setting up Our First Route

Even though we don't have any routes setup in our app, we can get the basic structure up and running. Our app currently runs from the `App` component in `src/App.js`. We are going to be using this component as the container for our entire app. To do that we'll create a file that will contain the information about all of our routes.

{% include code-marker.html %} Let's create `src/Routes.js` and add the following into it.

```coffee
import React from 'react';
import { Router, Route } from 'react-router';
import App from './App';

export default (props) => (
  <Router {...props}>
    <Route path="/" component={App} />
  </Router>
);
```

This is basically telling React Router to direct all the requests with the path `/` to the `App` component.

And now we'll head over to our `index.js` and use this newly created Router instead of the App component that we were using.

{% include code-marker.html %} Replace code in `src/index.js` with the following.

``` coffee
import React from 'react';
import ReactDOM from 'react-dom';
import Routes from './Routes';
import { browserHistory } from 'react-router';
import './index.css';

ReactDOM.render(
  <Routes history={browserHistory} />,
  document.getElementById('root')
);
```

We've made two small changes here.

1. Use the `Routes` component from `src/Routes.js` that we just created; instead of the `App` component.
2. Use `browserHistory` in our Router. This uses the browser's [History](https://developer.mozilla.org/en-US/docs/Web/API/History) API to create real URLs.

Now if you head over to your browser, your app should load just like before. The only difference being that we are using React Router to serve out our pages.

Next we are going to look into how to organize the different pages of our app.
