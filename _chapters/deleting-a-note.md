---
layout: post
title: Deleting a Note
date: 2017-01-31 00:00:00
---

The last thing we need to do on the note page is allowing users to delete their note. We have the button all set up already. All that needs to be done is to hook it up with the API.

Replace our `handleDelete` method with the following.

{% highlight javascript %}
deleteNote() {
  return invokeApig({
    path: `/notes/${this.props.params.id}`,
    method: 'DELETE',
  }, this.props.userToken);
}

handleDelete = async (event) => {
  event.preventDefault();

  const confirmed = confirm('Are you sure you want to delete this note?');

  if ( ! confirmed) {
    return;
  }

  this.setState({ isDeleting: true });

  try {
    await this.deleteNote();
    this.props.router.push('/');
  }
  catch(e) {
    alert(e);
    this.setState({ isDeleting: false });
  }
}
{% endhighlight %}

We are simply making a `DELETE` request to `/notes/note_id` where we get the id from `this.props.params.id`. This calls our delete API and we redirect to the homepage on success.

Now if you switch over to your browser and try deleting a note you should see it confirm your action and then delete the note.

![Note page deleting screenshot]({{ site.url }}/assets/note-page-deleting.png)

Now with our app nearly complete, we'll look at securing some the pages of our app that require a login. Currently if you visit a note page while you are logged out, it throws an ugly error.

![Note page logged out error screenshot]({{ site.url }}/assets/note-page-logged-out-error.png)

Instead, we would like it to redirect us to the login page and then redirect us back after we login.
