---
layout: post
title: Setup an Error Boundary in React
date: 2020-04-03 00:00:00
lang: en
description: 
comments_id: 
ref: setup-an-error-boundary-in-react
---

In the previous chapter we looked at how to [report API errors to Sentry in our React app]({% link _chapters/report-api-errors-in-react.md %}). Now let's report all those unexpected errors that might happen using a [React Error Boundary](https://reactjs.org/docs/error-boundaries.html).

An Error Boundary is component that allows us to catch any errors that might happen in the child components tree, log those errors, and show a fallback UI.

### Create an Error Boundary

It's incredibly straightforward to setup. So let's get started.

<img class="code-marker" src="/assets/s.png" />Add the following to `src/components/ErrorBoundary.js`.

``` coffee
import React from "react";
import { logError } from "../libs/errorLib";
import "./ErrorBoundary.css";

export default class ErrorBoundary extends React.Component {
  state = { hasError: false };

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    logError(error, errorInfo);
  }

  render() {
    return this.state.hasError ? (
      <div className="ErrorBoundary">
        <h3>Sorry there was a problem loading this page</h3>
      </div>
    ) : (
      this.props.children
    );
  }
}
```

The key part of this component is the `componentDidCatch` and `getDerivedStateFromError` methods. These get triggered when any of the child components have an unhandled error. We set the internal state, `hasError` to `true` to display our fallback UI. And we report the error to Sentry by calling `logError` with the `error` and `errorInfo` that comes with it.

Let's include some simple styles for this.

<img class="code-marker" src="/assets/s.png" />Create a `src/components/ErrorBoundary.css` file and add:

``` css
.ErrorBoundary {
  padding-top: 100px;
  text-align: center;
}
```

The styles we are using is very similar to our `NotFound` component. We use that when a user navigates to a page that we don't have a route for. 

### Use the Error Boundary

To use the Error Boundary component that we created, we'll need to add it to our app component.

<img class="code-marker" src="/assets/s.png" />Find the following in `src/App.js`.

``` coffee
<AppContext.Provider value={{ isAuthenticated, userHasAuthenticated }}>
  <Routes />
</AppContext.Provider>
```
<img class="code-marker" src="/assets/s.png" />And replace it with:

``` coffee
<ErrorBoundary>
  <AppContext.Provider value={{ isAuthenticated, userHasAuthenticated }}>
    <Routes />
  </AppContext.Provider>
</ErrorBoundary>
```

<img class="code-marker" src="/assets/s.png" />Also, make sure to import it in header of `src/App.js`.

``` javascript
import ErrorBoundary from "./components/ErrorBoundary";
```

And that's it! Now an unhandled error in our containers will show a nice error message. While reporting the error to Sentry.

To do a quick test, replace the following in `src/containers/Home.js`.

``` javascript
{isAuthenticated ? renderNotes() : renderLander()}
```

With these faulty lines:

``` javascript
{isAuthenticated ? renderNotes() : renderLander()}
{ isAuthenticated.none.no }
```

Now in your browser you should see something like this.

![React error message](/assets/monitor-debug-errors/react-error-message.png)

While developing, React doesn't show your Error Boundary fallback UI by default. To view that, hit the **close** button on the top right.

![React Error Boundary fallback UI](/assets/monitor-debug-errors/react-error-boundary-fallback-ui.png)

Since we are developing locally, we don't report this error to Sentry. But let's do a quick test to make sure it's hooked up properly.

Replace the following from the top of `src/libs/error-lib.js`.

``` javascript
const isLocal = process.env.NODE_ENV === "development";
```

With:

``` javascript
const isLocal = false;
```

Now if we head over to our browser, we should see the error as before. And we should see the error being reported to Sentry as well!

![First error in Sentry](/assets/monitor-debug-errors/first-error-in-sentry.png)

And if you click through, you can see the error in detail.

![Error details in Sentry](/assets/monitor-debug-errors/error-details-in-sentry.png)

Now our React app is ready to handle the errors that are thrown its way. Next, let's look at handling errors in our Serverless app.
