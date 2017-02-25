---
layout: post
title: Add the User Token to the State
date: 2017-01-15 00:00:00
---

To complete the login process we would need to store the user token and update the app to reflect that the user has logged in.

### Store the User Token

First we'll start by storing the user token in the state. We might be tempted to store this in the `Login` container, but since we are going to use this in a lot of other places, it makes sense to lift up the state. The most logical place to do this will in our `App` component.

{% include code-marker.html %} Add the following to `src/App.js` right below the `export default class App extends Component {` line.

{% highlight javascript %}
constructor(props) {
  super(props);

  this.state = {
    userToken: null,
  };
}

updateUserToken = (userToken) => {
  this.setState({
    userToken: userToken
  });
}
{% endhighlight %}

This initializes the `userToken` in the App's state. And calling `updateUserToken` updates it. But for the `Login` container to call this method we need to pass a reference of this method to it.

### Plug into Login Container

We can do this by passing in a couple of props to the child components the `App` component creates. Currently, we create child components by doing the following line.

{% highlight javascript %}
{ this.props.children }
{% endhighlight %}

{% include code-marker.html %} In the `src/App.js`, replace it with the following.

{% highlight javascript %}
{ React.cloneElement(this.props.children, childProps) }
{% endhighlight %}

Also, initialize the `childProps` at the top of our render method.

{% include code-marker.html %} Add the following right below the `render() {` line in `src/App.js`.

{% highlight javascript %}
const childProps = {
  userToken: this.state.userToken,
  updateUserToken: this.updateUserToken,
};
{% endhighlight %}

And on the other side of this in the `Login` container we'll call the `updateUserToken` method.

{% include code-marker.html %} Replace the `alert(userToken);` line with the following in `src/containers/Login.js`.

{% highlight javascript %}
this.props.updateUserToken(userToken);
{% endhighlight %}

### Create a Logout Button

We can now use this to display a Logout button once the user logs in. Find the following in our `src/App.js`.

{% highlight javascript %}
<LinkContainer to="/signup">
  <NavItem>Signup</NavItem>
</LinkContainer>
<LinkContainer to="/login">
  <NavItem>Login</NavItem>
</LinkContainer>
{% endhighlight %}

{% include code-marker.html %} And replace it with this:

{% highlight javascript %}
{ this.state.userToken
  ? <NavItem onClick={this.handleLogout}>Logout</NavItem>
  : [ <LinkContainer key="1" to="/signup">
        <NavItem>Signup</NavItem>
      </LinkContainer>,
      <LinkContainer key="2" to="/login">
        <NavItem>Login</NavItem>
      </LinkContainer> ] }
{% endhighlight %}

{% include code-marker.html %} And add this `handleLogout` method to `src/App.js` above the `render() {` line as well.

{% highlight javascript %}
handleLogout = (event) => {
  this.updateUserToken(null);
}
{% endhighlight %}

Now head over to your browser and try logging in with the admin credentials we created in the Cognito User Pool chapter. You should see the Logout button appear right away.

![Login state updated screenshot]({{ site.url }}/assets/login-state-updated.png)

Now if you refresh your page you should be logged out again. This is because we are not initializing the state from the browser session. Let's look at how to do that next.
