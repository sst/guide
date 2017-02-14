---
layout: post
title: Clear the Session on Logout
---

Currently we are only removing the user token from our app's state. But when we refresh the page, we load the user token from the browser session, in effect logging them back in.

To clear the browser session on logout replace the `handleLogout` method with the following.

{% highlight javascript %}
handleLogout = (event) => {
  const currentUser = this.getCurrentUser();

  if (currentUser !== null) {
    currentUser.signOut();
  }

  this.updateUserToken(null);
}
{% endhighlight %}

Now if you head over to your browser, logout and then refresh the page; you should be logouted completely.

If you can try out the entire login flow from the beginning you'll notice that, we are constanly stuck on the login page through the entire process. Next, we'll look at redirecting the page after we login and logout to make it so that the flow makes more sense.
