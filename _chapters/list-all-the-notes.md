---
layout: post
title: List All the Notes
---

Now that we are able to create a new note. Let's create a page where we can see a list of all the notes a user has created. It makes sense that this would be the home page (even though we use the `/` route for the landing page). So we just need to conditionally render the landing page or the home page depending on the user session.

Currently, our `src/containers/Home.js` is very simple. Let's add the conditional rendering in there. Replace our `src/containers/Home.js` with the following.

{% highlight javascript %}
import React, { Component } from 'react';
import { withRouter } from 'react-router';
import {
  PageHeader,
  ListGroup,
} from 'react-bootstrap';
import './Home.css';

class Home extends Component {

  constructor(props) {
    super(props);

    this.state = {
      isLoading: false,
      notes: [],
    };
  }

  renderNotesList(notes) {
    return null;
  }

  renderLander() {
    return (
      <div className="lander">
        <h1>Scratch</h1>
        <p>A simple note taking app</p>
      </div>
    );
  }

  renderNotes() {
    return (
      <div className="notes">
        <PageHeader>Your Notes</PageHeader>
        <ListGroup>
          { ! this.state.isLoading
            && this.renderNotesList(this.state.notes) }
        </ListGroup>
      </div>
    );
  }

  render() {
    return (
      <div className="Home">
        { this.props.userToken === null
          ? this.renderLander()
          : this.renderNotes() }
      </div>
    );
  }
}

export default withRouter(Home);
{% endhighlight %}

We are doing a few simple things here.

1. Rendering the lander or the list of notes based on `this.props.userToken`.

2. Store our notes in the state. Currently, it's empty but we'll be calling our API for it.

3. Once we fetch our list we'll use the `renderNotesList` method to render the items in the list.

And that's our basic setup. Head over to the browser and the homepage of our app should render out an empty list.

![Empty home page loaded screenshot]({{ site.url }}/assets/empty-home-page-loaded.png)

Next we are going to fill it up with our API.
