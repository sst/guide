---
layout: post
title: Redirect on Login and Logout
---

To complete the login flow we are going to need to do two more things.

1. Redirect the user to the home page after the login
2. And redirect them back to the login page after they logout

This gives us a chance to explore how to do redirects with React-Router.

React-Router comes with a [Higher-Order Component](https://facebook.github.io/react/docs/higher-order-components.html) (or HOC) called `withRouter` that gives us direct acces to our app's router from any component.

### Redirect to Home on Login

To use it in our Login component, let's replace the line that defines our component.

{% highlight javascript %}
export default class Login extends Component {
{% endhighlight %}

with the following.

{% highlight javascript %}
class Login extends Component {
{% endhighlight %}

And instead export it in the following way.

{% highlight javascript %}
export default withRouter(Login);
{% endhighlight %}

Also, import the `withRouter` in the header.

{% highlight javascript %}
import { withRouter } from 'react-router';
{% endhighlight %}

Now we can use the router after a successful login by doing the following.

{% highlight javascript %}
this.props.router.push('/');
{% endhighlight %}

Our updated `handleSubmit` method in our `Login` component should look like this.

{% highlight javascript %}
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
{% endhighlight %}

Now if you head over to your browser and try logging in, you should be redirected to the home page after you've been logged in.

![Redirect home after login screenshot]({{ site.url }}/assets/redirect-home-after-login.png)

### Redirect to Login After Logout

Now we'll do something very simillar for the logout process.

Define our App component by doing this instead.

{% highlight javascript %}
class App extends Component {
{% endhighlight %}

And export it after calling `withRouter`.

{% highlight javascript %}
export default withRouter(App);
{% endhighlight %}

Import `withRouter` along with `IndexLink`.

{% highlight javascript %}
import { withRouter, IndexLink } from 'react-router';
{% endhighlight %}

And finally, redirect after logut by doing the following.

{% highlight javascript %}
if (this.props.location.pathname !== '/login') {
  this.props.router.push('/login');
}
{% endhighlight %}

Now if you swtich your browser and trying logging out, you should be redirected to the login page.

You might have noticed while testing this flow that since the login call has a bit of a delay, it would be important to give some feedback to the user that it is in progress.
