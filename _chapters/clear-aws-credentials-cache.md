---
layout: post
title: Create AWS Credentials Cache
---

To be able to upload our files to S3 we needed to get the AWS credentials first. And the AWS JS SDK saves those credentials temporarily.

But we need to make sure that we clear out those credentials when we logout. To do that let's add the following lines to the `handleLogout` method in our `src/App.js`.

{% highlight javascript %}
if (AWS.config.credentials) {
  AWS.config.credentials.clearCachedId();
}
{% endhighlight %}

So our `handleLogout` should now look like the following.

{% highlight javascript %}
handleLogout = (event) => {
  const currentUser = this.getCurrentUser();

  if (currentUser !== null) {
    currentUser.signOut();
  }

  if (AWS.config.credentials) {
    AWS.config.credentials.clearCachedId();
  }

  this.updateUserToken(null);

  if (this.props.location.pathname !== '/login') {
    this.props.router.push('/login');
  }
}
{% endhighlight %}

And include the AWS SDK in the header.

{% highlight javascript %}
import AWS from 'aws-sdk';
{% endhighlight %}

Next up we are going to allow users to see a list of their notes.
