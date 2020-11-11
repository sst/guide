---
layout: post
title: Setup an Error Boundary in React
date: 2020-04-03 00:00:00
lang: en
description: In this chapter we look at how to handle unexpected errors in our React app using an Error Boundary component. It lets us catch any errors, log it to Sentry, and show a fallback UI.
code: frontend_full
comments_id: setup-an-error-boundary-in-react/1732
ref: setup-an-error-boundary-in-react
---

In the previous chapter we looked at how to [report API errors to Sentry in our React app]({% link _chapters/report-api-errors-in-react.md %}). Now let's report all those unexpected errors that might happen using a [React Error Boundary](https://reactjs.org/docs/error-boundaries.html).

An Error Boundary is a component that allows us to catch any errors that might happen in the child components tree, log those errors, and show a fallback UI.

### Create an Error Boundary

It's incredibly straightforward to setup. So let's get started.

{%change%} Add the following to `src/components/ErrorBoundary.js`.

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

{%change%} Create a `src/components/ErrorBoundary.css` file and add:

``` css
.ErrorBoundary {
  padding-top: 100px;
  text-align: center;
}
```

The styles we are using are very similar to our `NotFound` component. We use that when a user navigates to a page that we don't have a route for. 

### Use the Error Boundary

To use the Error Boundary component that we created, we'll need to add it to our app component.

{%change%} Find the following in `src/App.js`.

{% raw %}
``` coffee
<AppContext.Provider value={{ isAuthenticated, userHasAuthenticated }}>
  <Routes />
</AppContext.Provider>
```
{% endraw %}

{%change%} And replace it with:

{% raw %}
``` coffee
<ErrorBoundary>
  <AppContext.Provider value={{ isAuthenticated, userHasAuthenticated }}>
    <Routes />
  </AppContext.Provider>
</ErrorBoundary>
```
{% endraw %}

{%change%} Also, make sure to import it in the header of `src/App.js`.

``` javascript
import ErrorBoundary from "./components/ErrorBoundary";
```

And that's it! Now an unhandled error in our containers will show a nice error message. While reporting the error to Sentry.

### Commit the Changes

{%change%} Let's quickly commit these to Git.

``` bash
$ git add .
$ git commit -m "Adding error reporting"
```

### Push the Changes

{%change%} Let's also push these changes to GitHub and deploy our app.

``` bash
$ git push
```

### Test the Error Boundary

Before we move on, let's do a quick test.

Replace the following in `src/containers/Home.js`.

``` javascript
{isAuthenticated ? renderNotes() : renderLander()}
```

With these faulty lines:

{% raw %}
``` javascript
{isAuthenticated ? renderNotes() : renderLander()}
{ isAuthenticated.none.no }
```
{% endraw %}

Now in your browser you should see something like this.

![React error message](/assets/monitor-debug-errors/react-error-message.png)

While developing, React doesn't show your Error Boundary fallback UI by default. To view that, hit the **close** button on the top right.

![React Error Boundary fallback UI](/assets/monitor-debug-errors/react-error-boundary-fallback-ui.png)

Since we are developing locally, we don't report this error to Sentry. But let's do a quick test to make sure it's hooked up properly.

Replace the following from the top of `src/libs/errorLib.js`.

``` javascript
const isLocal = process.env.NODE_ENV === "development";
```

With:

``` javascript
const isLocal = false;
```

Now if we head over to our browser, we should see the error as before. And we should see the error being reported to Sentry as well! It might take a moment or two before it shows up.

![First error in Sentry](/assets/monitor-debug-errors/first-error-in-sentry.png)

And if you click through, you can see the error in detail.

![Error details in Sentry](/assets/monitor-debug-errors/error-boundary-error-details-in-sentry.png)

Now our React app is ready to handle the errors that are thrown its way!

Let's cleanup all the testing changes we made above.


``` bash
$ git checkout .
```

Next, let's look at how to handle errors in our Serverless app.
