---
layout: post
title: Render the Note Form
date: 2017-01-29 00:00:00
lang: en
description: We are going to render a user’s note in a form in our React.js app. To render the form fields, we’ll use React-Bootstrap’s FormGroup and FormControl components.
context: true
comments_id: render-the-note-form/140
ref: render-the-note-form
---

Now that our container loads a note on `componentDidMount`, let's go ahead and render the form that we'll use to edit it.

<img class="code-marker" src="/assets/s.png" />Replace our placeholder `render` method in `src/containers/Notes.js` with the following.

``` javascript
function validateForm() {
  return state.content.length > 0;
}

function formatFilename(str) {
  return str.replace(/^\w+-/, "");
}

function handleChange(event) {
  dispatch({
    type: "change",
    field: event.target.id,
    value: event.target.value
  });
}

function handleFileChange(event) {
  file.current = event.target.files[0];
}

async function handleSubmit(event) {
  event.preventDefault();

  if (file.current && file.current.size > config.MAX_ATTACHMENT_SIZE) {
    alert(`Please pick a file smaller than ${config.MAX_ATTACHMENT_SIZE/1000000} MB.`);
    return;
  }

  dispatch({ type: "submitting" });
}

async function handleDelete(event) {
  event.preventDefault();

  const confirmed = window.confirm(
    "Are you sure you want to delete this note?"
  );

  if (!confirmed) {
    return;
  }

  dispatch({ type: "deleting" });
}

return (
  <div className="Notes">
    {state.note &&
      <form onSubmit={handleSubmit}>
        <FormGroup controlId="content">
          <FormControl
            value={state.content}
            componentClass="textarea"
            onChange={handleChange}
          />
        </FormGroup>
        {state.note.attachment &&
          <FormGroup>
            <ControlLabel>Attachment</ControlLabel>
            <FormControl.Static>
              <a
                target="_blank"
                rel="noopener noreferrer"
                href={state.attachmentURL}
              >
                {formatFilename(state.note.attachment)}
              </a>
            </FormControl.Static>
          </FormGroup>}
        <FormGroup controlId="file">
          {!state.note.attachment &&
            <ControlLabel>Attachment</ControlLabel>}
          <FormControl onChange={handleFileChange} type="file" />
        </FormGroup>
        <LoaderButton
          block
          text="Save"
          type="submit"
          bsSize="large"
          bsStyle="primary"
          loadingText="Saving…"
          isLoading={state.isLoading}
          disabled={!validateForm()}
        />
        <LoaderButton
          block
          text="Delete"
          bsSize="large"
          bsStyle="danger"
          loadingText="Deleting…"
          onClick={handleDelete}
          isLoading={state.isDeleting}
        />
      </form>}
  </div>
);
```

REWRITE

We are doing a few things here:

1. We render our form only when `this.state.note` is available.

2. Inside the form we conditionally render the part where we display the attachment by using `this.state.note.attachment`.

3. We format the attachment URL using `formatFilename` by stripping the timestamp we had added to the filename while uploading it.

4. We also added a delete button to allow users to delete the note. And just like the submit button it too needs a flag that signals that the call is in progress. We call it `isDeleting`.

5. We handle attachments with a file input exactly like we did in the `NewNote` component.

6. Our delete button also confirms with the user if they want to delete the note using the browser's `confirm` dialog.

To complete this code, let's add `isLoading` and `isDeleting` to the state.

<img class="code-marker" src="/assets/s.png" />So our new initial state in the `constructor` looks like so.

``` javascript
const [state, dispatch] = useReducer(reducer, {
  note: null,
  content: "",
  isLoading: null,
  isDeleting: null,
  attachmentURL: null
});
```

REWRITE

``` javascript
function reducer(state, action) {
  switch (action.type) {
    case "load":
      return {
        ...state,
        note: action.note,
        content: action.content,
        attachmentURL: action.attachmentURL
      };
    case "change":
      return {
        ...state,
        [action.field]: action.value
      };
    case "submitting":
      return {
        ...state,
        isLoading: true
      };
    case "deleting":
      return {
        ...state,
        isDeleting: true
      };
    default:
      throw new Error();
  }
}
```

<img class="code-marker" src="/assets/s.png" />Let's also add some styles by adding the following to `src/containers/Notes.css`.

``` css
.Notes form {
  padding-bottom: 15px;
}

.Notes form textarea {
  height: 300px;
  font-size: 24px;
}
```

<img class="code-marker" src="/assets/s.png" />Also, let's include the React-Bootstrap components that we are using here by adding the following to our header. And our styles, the `LoaderButton`, and the `config`.

``` javascript
import { FormGroup, FormControl, ControlLabel } from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
import config from "../config";
import "./Notes.css";
```

And that's it. If you switch over to your browser, you should see the note loaded.

![Notes page loaded screenshot](/assets/notes-page-loaded.png)

Next, we'll look at saving the changes we make to our note.
