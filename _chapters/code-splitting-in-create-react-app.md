---
layout: post
title: Code Splitting in Create React App
description: Code splitting in Create React App is an easy way to reduce the size of your React.js app bundle. To do this in an app using React Router v4, we can asynchronously load our routes using the dynamic import() method that Create React App supports.
date: 2018-04-17 00:00:00
code: frontend
comments_id: code-splitting-in-create-react-app/98
---

Code Splitting is not a necessary step for building React apps. But feel free to follow along if you are curious about what Code Splitting is and how it can help larger React apps.

### Code Splitting

While working on React.js single page apps, there is a tendency for apps to grow quite large. A section of the app (or route) might import a large number of components that are not necessary when it first loads. This hurts the initial load time of our app.

You might have noticed that Create React App will generate one large `.js` file while we are building our app. This contains all the JavaScript our app needs. But if a user is simply loading the login page to sign in; it doesn't make sense that we load the rest of the app with it. This isn't a concern early on when our app is quite small but it becomes an issue down the road. To address this, Create React App has a very simple built-in way to split up our code. This feature unsurprisingly, is called Code Splitting.

Create React App (from 1.0 onwards) allows us to dynamically import parts of our app using the `import()` proposal. You can read more about it [here](https://facebook.github.io/react/blog/2017/05/18/whats-new-in-create-react-app.html#code-splitting-with-dynamic-import).

While, the dynamic `import()` can be used for any component in our React app; it works really well with React Router. Since, React Router is figuring out which component to load based on the path; it would make sense that we dynamically import those components only when we navigate to them.

### Code Splitting and React Router v4

The usual structure used by React Router to set up routing for your app looks something like this.

``` coffee
/* Import the components */
import Home from "./containers/Home";
import Posts from "./containers/Posts";
import NotFound from "./containers/NotFound";

/* Use components to define routes */
export default () =>
  <Switch>
    <Route path="/" exact component={Home} />
    <Route path="/posts/:id" exact component={Posts} />
    <Route component={NotFound} />
  </Switch>;
```

We start by importing the components that will respond to our routes. And then use them to define our routes. The `Switch` component renders the route that matches the path.

However, we import all of the components in the route statically at the top. This means, that all these components are loaded regardless of which route is matched. To implement Code Splitting here we are going to want to only load the component that responds to the matched route.

### Create an Async Component

To do this we are going to dynamically import the required component.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/components/AsyncComponent.js`.

``` coffee
import React, { Component } from "react";

export default function asyncComponent(importComponent) {
  class AsyncComponent extends Component {
    constructor(props) {
      super(props);

      this.state = {
        component: null
      };
    }

    async componentDidMount() {
      const { default: component } = await importComponent();

      this.setState({
        component: component
      });
    }

    render() {
      const C = this.state.component;

      return C ? <C {...this.props} /> : null;
    }
  }

  return AsyncComponent;
}
```

We are doing a few things here:

1. The `asyncComponent` function takes an argument; a function (`importComponent`) that when called will dynamically import a given component. This will make more sense below when we use `asyncComponent`.
2. On `componentDidMount`, we simply call the `importComponent` function that is passed in. And save the dynamically loaded component in the state.
3. Finally, we conditionally render the component if it has completed loading. If not we simply render `null`. But instead of rendering `null`, you could render a loading spinner. This would give the user some feedback while a part of your app is still loading.

### Use the Async Component

Now let's use this component in our routes. Instead of statically importing our component.

``` coffee
import Home from "./containers/Home";
```

We are going to use the `asyncComponent` to dynamically import the component we want.

``` coffee
const AsyncHome = asyncComponent(() => import("./containers/Home"));
```

It's important to note that we are not doing an import here. We are only passing in a function to `asyncComponent` that will dynamically `import()` when the `AsyncHome` component is created.

Also, it might seem weird that we are passing a function here. Why not just pass in a string (say `./containers/Home`) and then do the dynamic `import()` inside the `AsyncComponent`? This is because we want to explicitly state the component we are dynamically importing. Webpack splits our app based on this. It looks at these imports and generates the required parts (or chunks). This was pointed out by [@wSokra](https://twitter.com/wSokra/status/866703557323632640) and [@dan_abramov](https://twitter.com/dan_abramov/status/866646657437491201).

We are then going to use the `AsyncHome` component in our routes. React Router will create the `AsyncHome` component when the route is matched and that will in turn dynamically import the `Home` component and continue just like before.

``` coffee
<Route path="/" exact component={AsyncHome} />
```

Now let's go back to our Notes project and apply these changes.

<img class="code-marker" src="/assets/s.png" />Your `src/Routes.js` should look like this after the changes.

``` coffee
import React from "react";
import { Route, Switch } from "react-router-dom";
import asyncComponent from "./components/AsyncComponent";
import AppliedRoute from "./components/AppliedRoute";
import AuthenticatedRoute from "./components/AuthenticatedRoute";
import UnauthenticatedRoute from "./components/UnauthenticatedRoute";

const AsyncHome = asyncComponent(() => import("./containers/Home"));
const AsyncLogin = asyncComponent(() => import("./containers/Login"));
const AsyncNotes = asyncComponent(() => import("./containers/Notes"));
const AsyncSignup = asyncComponent(() => import("./containers/Signup"));
const AsyncNewNote = asyncComponent(() => import("./containers/NewNote"));
const AsyncNotFound = asyncComponent(() => import("./containers/NotFound"));

export default ({ childProps }) =>
  <Switch>
    <AppliedRoute
      path="/"
      exact
      component={AsyncHome}
      props={childProps}
    />
    <UnauthenticatedRoute
      path="/login"
      exact
      component={AsyncLogin}
      props={childProps}
    />
    <UnauthenticatedRoute
      path="/signup"
      exact
      component={AsyncSignup}
      props={childProps}
    />
    <AuthenticatedRoute
      path="/notes/new"
      exact
      component={AsyncNewNote}
      props={childProps}
    />
    <AuthenticatedRoute
      path="/notes/:id"
      exact
      component={AsyncNotes}
      props={childProps}
    />
    {/* Finally, catch all unmatched routes */}
    <Route component={AsyncNotFound} />
  </Switch>
;
```

It is pretty cool that with just a couple of changes, our app is all set up for code splitting. And without adding a whole lot more complexity either! Here is what our `src/Routes.js` looked like before.

``` coffee
import React from "react";
import { Route, Switch } from "react-router-dom";
import AppliedRoute from "./components/AppliedRoute";
import AuthenticatedRoute from "./components/AuthenticatedRoute";
import UnauthenticatedRoute from "./components/UnauthenticatedRoute";

import Home from "./containers/Home";
import Login from "./containers/Login";
import Notes from "./containers/Notes";
import Signup from "./containers/Signup";
import NewNote from "./containers/NewNote";
import NotFound from "./containers/NotFound";

export default ({ childProps }) =>
  <Switch>
    <AppliedRoute
      path="/"
      exact
      component={Home}
      props={childProps}
    />
    <UnauthenticatedRoute
      path="/login"
      exact
      component={Login}
      props={childProps}
    />
    <UnauthenticatedRoute
      path="/signup"
      exact
      component={Signup}
      props={childProps}
    />
    <AuthenticatedRoute
      path="/notes/new"
      exact
      component={NewNote}
      props={childProps}
    />
    <AuthenticatedRoute
      path="/notes/:id"
      exact
      component={Notes}
      props={childProps}
    />
    {/* Finally, catch all unmatched routes */}
    <Route component={NotFound} />
  </Switch>
;
```

Notice that instead of doing the static imports for all the containers at the top, we are creating these functions that are going to do the dynamic imports for us when necessary.

Now if you build your app using `npm run build`; you'll see the code splitting in action.

![Create React App Code Splitting build screenshot](/assets/create-react-app-code-splitting-build.png)

Each of those `.chunk.js` files are the different dynamic `import()` calls that we have.  Of course, our app is quite small and the various parts that are split up are not significant at all. However, if the page that we use to edit our note included a rich text editor; you can imagine how that would grow in size. And it would unfortunately affect the initial load time of our app.

Now if we deploy our app using `npm run deploy`; you can see the browser load the different chunks on-demand as we browse around in the [demo](https://demo.serverless-stack.com). 

![Create React App loading Code Splitting screenshot](/assets/create-react-app-loading-code-splitting.png)

That's it! With just a few simple changes our app is completely set up to use the code splitting feature that Create React App has.

### Next Steps

Now this seems really easy to implement but you might be wondering what happens if the request to import the new component takes too long, or fails. Or maybe you want to preload certain components. For example, a user is on your login page about to login and you want to preload the homepage.

It was mentioned above that you can add a loading spinner while the import is in progress. But we can take it a step further and address some of these edge cases. There is an excellent higher order component that does a lot of this well; it's called [**react-loadable**](https://github.com/thejameskyle/react-loadable).

All you need to do to use it is install it.

``` bash
$ npm install --save react-loadable
```

Use it instead of the `asyncComponent` that we had above.

``` coffee
const AsyncHome = Loadable({
  loader: () => import("./containers/Home"),
  loading: MyLoadingComponent
});
```

And `AsyncHome` is used exactly as before. Here the `MyLoadingComponent` would look something like this.

``` coffee
const MyLoadingComponent = ({isLoading, error}) => {
  // Handle the loading state
  if (isLoading) {
    return <div>Loading...</div>;
  }
  // Handle the error state
  else if (error) {
    return <div>Sorry, there was a problem loading the page.</div>;
  }
  else {
    return null;
  }
};
```

It's a simple component that handles all the different edge cases gracefully.

To add preloading and to further customize this; make sure to check out the other options and features that [react-loadable](https://github.com/thejameskyle/react-loadable) has. And have fun code splitting!
