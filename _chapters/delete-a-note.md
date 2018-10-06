---
layout: post
title: Delete a Note
date: 2017-01-31 00:00:00
description: We want users to be able to delete their note in our React.js app. To do this we are going to make a DELETE request to our serverless API backend using AWS Amplify.
context: true
comments_id: comments-for-delete-a-note/137
---

The last thing we need to do on the note page is allowing users to delete their note. We have the button all set up already. All that needs to be done is to hook it up with the API.

<img class="code-marker" src="/assets/s.png" />Replace our `handleDelete` method in `src/containers/Notes.js`.

``` coffee
deleteNote() {
  return API.del("notes", `/notes/${this.props.match.params.id}`);
}

handleDelete = async event => {
  event.preventDefault();

  const confirmed = window.confirm(
    "Are you sure you want to delete this note?"
  );

  if (!confirmed) {
    return;
  }

  this.setState({ isDeleting: true });

  try {
    await this.deleteNote();
    this.props.history.push("/");
  } catch (e) {
    alert(e);
    this.setState({ isDeleting: false });
  }
}
```

We are simply making a `DELETE` request to `/notes/:id` where we get the `id` from `this.props.match.params.id`. We use the `API.del` method from AWS Amplify to do so. This calls our delete API and we redirect to the homepage on success.

Now if you switch over to your browser and try deleting a note you should see it confirm your action and then delete the note.

![Note page deleting screenshot](/assets/note-page-deleting.png)

Again, you might have noticed that we are not deleting the attachment when we are deleting a note. We are leaving that up to you to keep things simple. Check the [AWS Amplify API Docs](https://aws.github.io/aws-amplify/api/classes/storageclass.html#remove) on how to a delete file from S3.

Now with our app nearly complete, we'll look at securing some the pages of our app that require a login. Currently if you visit a note page while you are logged out, it throws an ugly error.

![Note page logged out error screenshot](/assets/note-page-logged-out-error.png)

Instead, we would like it to redirect us to the login page and then redirect us back after we login. Let's look at how to do that next.
