---
layout: post
title: Save Changes to a Note
date: 2017-01-30 00:00:00
---

Now that our note loads into our form, let's work on saving the changes we make to that note.

{% include code-marker.html %} Replace the `handleSubmit` method in `src/containers/Notes.js` with the following.

``` javascript
saveNote(note) {
  return invokeApig({
    path: `/notes/${this.props.params.id}`,
    method: 'PUT',
    body: note,
  }, this.props.userToken);
}

handleSubmit = async (event) => {
  let uploadedFilename;

  event.preventDefault();

  if (this.file && this.file.size > config.MAX_ATTACHMENT_SIZE) {
    alert('Please pick a file smaller than 5MB');
    return;
  }

  this.setState({ isLoading: true });

  try {

    if (this.file) {
      uploadedFilename = await s3Upload(this.file, this.props.userToken);
    }

    await this.saveNote({
      ...this.state.note,
      content: this.state.content,
      attachment: uploadedFilename || this.state.note.attachment,
    });
    this.props.router.push('/');
  }
  catch(e) {
    alert(e);
    this.setState({ isLoading: false });
  }
}
```

{% include code-marker.html %} And include our `s3Upload` helper method in the header:

``` javascript
import { invokeApig, s3Upload } from '../libs/awsLib.js';
```

The code above is doing a couple of things that should be very similar to what we did in the `NewNote` container.

1. If there is a file to upload we call `s3Upload` to upload it and return the URL.

2. We save the note by making `PUT` request with the note object to `/notes/note_id` where we get the note_id from `this.props.params.id`.

3. And on success we redirect the user to the homepage.

Let's switch over to our browser and give it a try by saving some changes.

![Notes page saving screenshot]({{ site.url }}/assets/notes-page-saving.png)

Next up, let's allow users to delete their note.
