---
layout: post
title: Add the User Token to the State
---

To complete the login process we would need to store the user token and update the app to reflect that the user has logged in.

### Store the User Token

First we'll start by storing the user token that we just retrieved in the state. We might be tempted to store this in the `Login` container but since we are going to use this in a lot of other places it makes sense to lift up the state. The most logical place to do this will in our `App` component.

Add the following to our `App` component.

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

This initializes the `userToken` in the App's state. And calling `updateUserToken` updates it. But for the `Login` container to call this method we need to pass this to it.

### Plug into Login Container

We can do this by passing in a couple of props to the child components the `App` component creates. Currently, we create child components using the following line.

{% highlight javascript %}
{ this.props.children }
{% endhighlight %}

Replace this with the following.

{% highlight javascript %}
{ React.cloneElement(this.props.children, childProps) }
{% endhighlight %}

Where `childProps` is initialized at the top of our `render` mehtod by doing the following.

{% highlight javascript %}
const childProps = {
  userToken: this.state.userToken,
  updateUserToken: this.updateUserToken,
};
{% endhighlight %}

And on the other side of this in the `Login` container instead of displaying the `userToken` in an alert we'll call the `updateUserToken` method.

{% highlight javascript %}
this.props.updateUserToken(userToken);
{% endhighlight %}

### Create a Logout Button

We can now use this to display a Logout button once the user logs in. Replace the following in the render method.

{% highlight javascript %}
<LinkContainer to="/signup">
  <NavItem>Signup</NavItem>
</LinkContainer>
<LinkContainer to="/login">
  <NavItem>Login</NavItem>
</LinkContainer>
{% endhighlight %}
 
With this bit of code that conditionally renders a Logout button.

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

And add the following `handleLogout` as well.

{% highlight javascript %}
handleLogout = (event) => {
  this.updateUserToken(null);
}
{% endhighlight %}

Now head over to your browser and try logging in with the admin credentials and you should see the Logout button appear right away.

![Login state updated screenshot]({{ site.url }}/assets/login-state-updated.png)

Now if you refresh your page you should be logged out again. This is because we are not initiliazing the state from the browser session. Let's look at how to do that next.
