---
layout: post
title: Call the Create API
date: 2017-01-23 00:00:00
context: frontend
code: frontend
comments_id: 48
---

Now that we know how to connect to API Gateway securely, let's make the API call to create our note.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Let's include our `awsLib` by adding the following to the header of `src/containers/NewNote.js`.

``` javascript
import { invokeApig } from '../libs/awsLib';
```

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And replace our `handleSubmit` function with the following.

``` javascript
handleSubmit = async (event) => {
  event.preventDefault();

  if (this.file && this.file.size > config.MAX_ATTACHMENT_SIZE) {
    alert('Please pick a file smaller than 5MB');
    return;
  }

  this.setState({ isLoading: true });

  try {
    await this.createNote({
      content: this.state.content,
    });
    this.props.history.push('/');
  }
  catch(e) {
    alert(e);
    this.setState({ isLoading: false });
  }

}

createNote(note) {
  return invokeApig({
    path: '/notes',
    method: 'POST',
    body: note,
  }, this.props.userToken);
}
```

This does a couple of simple things.

1. We make our create call in `createNote` by making a POST request to `/notes` and passing in our note object.

2. For now the note object is simply the content of the note. We are creating these notes without an attachment for now.

3. Finally, after the note is created we redirect to our homepage.

And that's it; if you switch over to your browser and try submitting your form, it should successfully navigate over to our homepage.

![New note created screenshot]({{ site.url }}/assets/new-note-created.png)

Next let's upload our file to S3 and add an attachment to our note.
