---
layout: post
title: Add the Create Note Page
date: 2017-01-22 00:00:00
lang: en
ref: add-the-create-note-page
description: We would like users to be able to create a note in our React.js app and upload a file as an attachment. To do so we are first going to create a form using the FormGroup and FormControl React-Bootstrap components.
comments_id: add-the-create-note-page/107
---

Now that we can signup users and also log them in. Let's get started with the most important part of our note taking app; the creation of a note.

First we are going to create the form for a note. It'll take some content and a file as an attachment.

### Add the Container

{%change%} Create a new file `src/containers/NewNote.js` and add the following.

``` coffee
import React, { useRef, useState } from "react";
import { useHistory } from "react-router-dom";
import { FormGroup, FormControl, ControlLabel } from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
import { onError } from "../libs/errorLib";
import config from "../config";
import "./NewNote.css";

export default function NewNote() {
  const file = useRef(null);
  const history = useHistory();
  const [content, setContent] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  function validateForm() {
    return content.length > 0;
  }

  function handleFileChange(event) {
    file.current = event.target.files[0];
  }

  async function handleSubmit(event) {
    event.preventDefault();

    if (file.current && file.current.size > config.MAX_ATTACHMENT_SIZE) {
      alert(
        `Please pick a file smaller than ${config.MAX_ATTACHMENT_SIZE /
          1000000} MB.`
      );
      return;
    }

    setIsLoading(true);
  }

  return (
    <div className="NewNote">
      <form onSubmit={handleSubmit}>
        <FormGroup controlId="content">
          <FormControl
            value={content}
            componentClass="textarea"
            onChange={e => setContent(e.target.value)}
          />
        </FormGroup>
        <FormGroup controlId="file">
          <ControlLabel>Attachment</ControlLabel>
          <FormControl onChange={handleFileChange} type="file" />
        </FormGroup>
        <LoaderButton
          block
          type="submit"
          bsSize="large"
          bsStyle="primary"
          isLoading={isLoading}
          disabled={!validateForm()}
        >
          Create
        </LoaderButton>
      </form>
    </div>
  );
}
```

Everything is fairly standard here, except for the file input. Our form elements so far have been [controlled components](https://facebook.github.io/react/docs/forms.html), as in their value is directly controlled by the state of the component. However, in the case of the file input we want the browser to handle this state. So instead of `useState` we'll use the `useRef` hook. The main difference between the two is that `useRef` does not cause the component to re-render. It simply tells React to store a value for us so that we can use it later. We can set/get the current value of a ref by using its `current` property. Just as we do when the user selects a file.

``` javascript
file.current = event.target.files[0];
```

Currently, our `handleSubmit` does not do a whole lot other than limiting the file size of our attachment. We are going to define this in our config.

{%change%} So add the following to our `src/config.js` below the `export default {` line.

``` txt
MAX_ATTACHMENT_SIZE: 5000000,
```

{%change%} Let's also add the styles for our form in `src/containers/NewNote.css`.

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

{%change%} Finally, add our container as a route in `src/Routes.js` below our signup route.

``` coffee
<Route exact path="/notes/new">
  <NewNote />
</Route>
```

{%change%} And include our component in the header.

``` javascript
import NewNote from "./containers/NewNote";
```

Now if we switch to our browser and navigate `http://localhost:3000/notes/new` we should see our newly created form. Try adding some content, uploading a file, and hitting submit to see it in action.

![New note page added screenshot](/assets/new-note-page-added.png)

Next, let's get into connecting this form to our API.
