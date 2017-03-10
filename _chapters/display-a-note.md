---
layout: post
title: Display a Note
date: 2017-01-28 00:00:00
code: frontend
---

Now that we have a listing of all the notes, let's create a page that displays a note and let's the user edit it.

The first thing we are going to need to do is load the note when our container loads. Just like what we did in the `Home` container. So let's get started.

### Add the Route

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Let's add a route for the note page that we are going to create by adding the following line to `src/Routes.js` below our `notes/new` route.

``` coffee
<Route path="notes/:id" component={Notes} />
```

This is important because we are going to be pattern matching to extract our note id from the URL.

By using the route path `notes/:id` we are telling the router to send all matching routes to our component `Notes`. This will also end up matching the route `notes/new` with an `id` of `new`. To ensure that doesn't happen, we put our `notes/new` route before the pattern matching one.

<img class="code-marker" src="{{ site.url }}/assets/s.png" />And include our component in the header.

``` javascript
import Notes from './containers/Notes';
```

Of course this component doesn't exist yet and we are going to create it now.

### Add the Container

<img class="code-marker" src="{{ site.url }}/assets/s.png" />Create a new file `src/containers/Notes.js` and add the following.

``` coffee
import React, { Component } from 'react';
import { withRouter } from 'react-router';
import { invokeApig } from '../libs/awsLib.js';

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
        note: results,
        content: results.content,
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
```

All this does is load the note on `componentWillMount` and save it to the state. We get the `id` of our note from the URL using the props automatically passed to us by React-Router in `this.props.params.id`. The keyword `id` is a part of the pattern matching in our route (`notes/:id`).

And now if you switch over to your browser and navigate to a note that we previously created, you'll notice that the page renders an empty container.

![Empty notes page loaded screenshot]({{ site.url }}/assets/empty-notes-page-loaded.png)

Next up, we are going to render the note we just loaded.
