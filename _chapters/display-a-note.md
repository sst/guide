---
layout: post
title: Display a Note
---

Now that we have a listing of all the notes, let's create a page that displays a note and let's the user edit it.

The first thing we are going to need to do is load the note when our container loads. Just like what we did in the `Home` container. So let's get started.

### Add the Route

Let's add a route for the note page that we are going to create by adding the following line to `src/Routes.js` below our `notes/new` route. This is important because we are going to pattern matching to extract our note id from the URL.

{% highlight javascript %}
<Route path="notes/:id" component={Notes} />
{% endhighlight %}

By using the route path `notes/:id` we are telling the router to send all matching routes to our component `Notes`. This will also end up matching the route `notes/new` with an `id` of `new`. To ensure that doesn't happen, we put our `notes/new` route before the pattern matching one.

And include our component in the header.

{% highlight javascript %}
import Notes from './containers/Notes';
{% endhighlight %}

Of course this component doesn't exist yet and we are going to create it now.

### Add the Container

Create a new file `src/containers/NewNote.js` and add the following.

{% highlight javascript %}
import React, { Component } from 'react';
import { withRouter } from 'react-router';
import { invokeApig } from '../lib/awsLib.js';

class Notes extends Component {
  constructor(props) {
    super(props);

    this.file = null;

    this.state = {
      note: null,
      content: '',
    };
  }

  async componentWillMount() {
    try {
      const results = await this.getNote();
      this.setState({
        note: results.data,
        content: results.data.content,
      });
    }
    catch(e) {
      alert(e);
    }
  }

  getNote() {
    return invokeApig({ path: `/notes/${this.props.params.id}` }, this.props.userToken);
  }

  render() {
    return (
      <div className="Notes">
      </div>
    );
  }
}

export default withRouter(Notes);
{% endhighlight %}

All this does is load the note on `componentWillMount` and save it to the state. We get the id of our note from the URL using the props automatically passed to us by React-Router in `this.props.params.id`. The keyword `id` is a part of the pattern matching in our route (`notes/:id`).

And now if you switch over to your browser and navigate to a note that we previously created, you'll notice that the page doesn't display an error anymore and renders and empty container.

![Empty notes page loaded screenshot]({{ site.url }}/assets/empty-notes-page-loaded.png)

Next up we are going to render the note we just loaded.
