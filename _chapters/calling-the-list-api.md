---
layout: post
title: Calling the List API
---

Now that we have our basic home page setup, let's make the API call to render our list of notes.

Add the following below the constructor in `src/containers/Home.js`.

{% highlight javascript %}
async componentWillMount() {
  if (this.props.userToken === null) {
    return;
  }

  try {
    const results = await this.notes();
    this.setState({ notes: results.data });
  }
  catch(e) {
    alert(e);
  }
}

notes() {
  return invokeApig({ path: '/notes' }, this.props.userToken);
}
{% endhighlight %}

And include our API Gateway Client helper in the header.

{% highlight javascript %}
import { invokeApig } from '../lib/awsLib.js';
{% endhighlight %}

All this does is make a GET request to `/notes` on `componentWillMount` and puts the results in `notes` object in the state.

Now let's render the results. Replace our `renderNotesList` placeholder method with the following.


{% highlight javascript %}
renderNotesList(notes) {
  return [{}].concat(notes).map((note, i) => (
    i !== 0
      ? ( <ListGroupItem
            key={note.noteId}
            href={`/notes/${note.noteId}`}
            onClick={this.onNoteClick}
            header={note.content.trim().split('\n')[0]}>
              { "Created: " + (new Date(note.createdAt)).toLocaleString() }
          </ListGroupItem> )
      : ( <ListGroupItem
            key="new"
            href="/notes/new"
            onClick={this.onNoteClick}>
              <h4><b>&#65291;</b> Create a new note</h4>
          </ListGroupItem> )
  ));
}

onNoteClick = (event) => {
  event.preventDefault();
  this.props.router.push(event.currentTarget.getAttribute('href'));
}
{% endhighlight %}

And include the `ListGroupItem` in the header so that our `react-bootstrap` import looks like so.

{% highlight javascript %}
import {
  PageHeader,
  ListGroup,
  ListGroupItem,
} from 'react-bootstrap';
{% endhighlight %}

The code above does a few things.

1. It always renders a **Create a new note** button as the first item in the list (even if the list is empty). We do this my concatinating an array with an empty object with our `notes` array.

2. We render the first line of each note as the `ListGroupItem` header by doing `note.content.trim().split('\n')[0]`.

3. And `onClick` for each of the list items we navigate to their respective pages.

Let's also add a couple of styles to our `src/containers/Home.css`.

{% highlight css %}
.Home .notes h4 {
  font-family: "Open Sans", sans-serif;
  overflow: hidden;
  line-height: 1.5;
  white-space: nowrap;
  text-overflow: ellipsis;
}
{% endhighlight %}

Now head over to your browser and you should see your list displayed.

![Home page list loaded screenshot]({{ site.url }}/assets/home-page-list-loaded.png)

And if you click on the links they should take you to their respoective pages.

Next up we are going to allow users to view and edit their notes.
