---
layout: post
title: Add the Create Note Page
date: 2017-01-22 00:00:00
---

Now that we can signup users and also log them in. Let's get started with the most important part of our note taking app; the creation of a note.

First we are going to create the form for a note. It'll take some content and a file as an attachment.

### Add the Container

{% include code-marker.html %} Create a new file `src/containers/NewNote.js` and add the following.

``` coffee
import React, { Component } from 'react';
import { withRouter } from 'react-router';
import {
  FormGroup,
  FormControl,
  ControlLabel,
} from 'react-bootstrap';
import LoaderButton from '../components/LoaderButton.js';
import config from '../config.js';
import './NewNote.css';

class NewNote extends Component {
  constructor(props) {
    super(props);

    this.file = null;

    this.state = {
      isLoading: null,
      content: '',
    };
  }

  validateForm() {
    return this.state.content.length > 0;
  }

  handleChange = (event) => {
    this.setState({
      [event.target.id]: event.target.value
    });
  }

  handleFileChange = (event) => {
    this.file = event.target.files[0];
  }

  handleSubmit = async (event) => {
    event.preventDefault();

    if (this.file && this.file.size > config.MAX_ATTACHMENT_SIZE) {
      alert('Please pick a file smaller than 5MB');
      return;
    }

    this.setState({ isLoading: true });
  }

  render() {
    return (
      <div className="NewNote">
        <form onSubmit={this.handleSubmit}>
          <FormGroup controlId="content">
            <FormControl
              onChange={this.handleChange}
              value={this.state.content}
              componentClass="textarea" />
          </FormGroup>
          <FormGroup controlId="file">
            <ControlLabel>Attachment</ControlLabel>
            <FormControl
              onChange={this.handleFileChange}
              type="file" />
          </FormGroup>
          <LoaderButton
            block
            bsStyle="primary"
            bsSize="large"
            disabled={ ! this.validateForm() }
            type="submit"
            isLoading={this.state.isLoading}
            text="Create"
            loadingText="Creating…" />
        </form>
      </div>
    );
  }
}

export default withRouter(NewNote);
```

Everything is fairly standard here, except for the file input. Our form elements so far have been [controlled components](https://facebook.github.io/react/docs/forms.html), as in their value is directly controlled by the state of the component. The file input simply calls a different `onChange` handler (`handleFileChange`) that saves the file object as a class property. We use a class property instead of saving it in the state because the file object we save does not change or drive the rendering of our component.

Currently, our `handleSubmit` does not do a whole lot other than limiting the file size of our attachment. We are going to define this in our config.

{% include code-marker.html %} So add the following to our `src/config.js` below the `export default {` line.

```
MAX_ATTACHMENT_SIZE: 5000000,
```

{% include code-marker.html %} Let's also add the styles for our form in `src/containers/NewNote.css`.

``` css
.NewNote form {
  padding-bottom: 15px;
}

.NewNote form textarea {
  height: 300px;
  font-size: 24px;
}
```

### Add the Route

{% include code-marker.html %} Finally, add our container as a route in `src/Routes.js` below our signup route.

``` coffee
<Route path="notes/new" component={NewNote} />
```

{% include code-marker.html %} And include our component in the header.

``` javascript
import NewNote from './containers/NewNote';
```

Now if we switch to our browser and navigate `http://localhost:3000/notes/new` we should see our newly created form. Try adding some content, uploading a file, and hitting submit to see it in action.

![New note page added screenshot]({{ site.url }}/assets/new-note-page-added.png)

Next, let's get into connecting this form to our API.
