---
layout: post
title: Redirect on Login and Logout
date: 2017-01-17 00:00:00
code: frontend
---

To complete the login flow we are going to need to do two more things.

1. Redirect the user to the home page after they login.
2. And redirect them back to the login page after they logout.

This gives us a chance to explore how to do redirects with React-Router.

React-Router comes with a [Higher-Order Component](https://facebook.github.io/react/docs/higher-order-components.html) (or HOC) called `withRouter` that gives us direct access to our app's router from any component.

### Redirect to Home on Login

{% include code-marker.html %} To use it in our `src/containers/Login.js`, let's replace the line that defines our component.

``` javascript
export default class Login extends Component {
```

{% include code-marker.html %} with the following:

``` javascript
class Login extends Component {
```

{% include code-marker.html %} And instead export it by adding this at the bottom of our `src/containers/Login.js`.

``` javascript
export default withRouter(Login);
```

{% include code-marker.html %} Also, import `withRouter` in the header.

``` javascript
import { withRouter } from 'react-router';
```

Now we can use the router after a successful login by doing the following.

``` javascript
this.props.router.push('/');
```

{% include code-marker.html %} Our updated `handleSubmit` method in `src/containers/Login.js` should look like this:

``` javascript
handleSubmit = async (event) => {
  event.preventDefault();

  try {
    const userToken = await this.login(this.state.username, this.state.password);
    this.props.updateUserToken(userToken);
    this.props.router.push('/');
  }
  catch(e) {
    alert(e);
  }
}
```

Now if you head over to your browser and try logging in, you should be redirected to the home page after you've been logged in.

![Redirect home after login screenshot]({{ site.url }}/assets/redirect-home-after-login.png)

### Redirect to Login After Logout

Now we'll do something very similar for the logout process.

{% include code-marker.html %} Define our `src/App.js` component by replacing the line below.

``` javascript
export default class App extends Component {
```

{% include code-marker.html %} with this:

``` javascript
class App extends Component {
```

{% include code-marker.html %} And export it after calling `withRouter` by adding this to the bottom of `src/App.js`.

``` javascript
export default withRouter(App);
```

{% include code-marker.html %} Import `withRouter` (along with the `IndexLink` from before) in the header of `src/App.js`.

``` javascript
import { withRouter, IndexLink } from 'react-router';
```

And finally, redirect after the logout.

{% include code-marker.html %} Add the following to the bottom of the `handleLogout` method in our `src/App.js`.

``` javascript
if (this.props.location.pathname !== '/login') {
  this.props.router.push('/login');
}
```

This redirects us back to the login page once the user logs out.

Now if you switch over to your browser and try logging out, you should be redirected to the login page.

You might have noticed while testing this flow that since the login call has a bit of a delay, we might need to give some feedback to the user that the login call is in progress. Let's do that next.
