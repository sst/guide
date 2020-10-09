---
layout: post
title: Call the List API
date: 2017-01-27 00:00:00
lang: en
description: To display a list of all of the user’s notes in our React.js app, we are going to make a GET request to our serverless API backend using the AWS Amplify API module. We are also going to use the ListGroup and ListGroupItem React-Bootstrap components to render the list.
comments_id: call-the-list-api/127
ref: call-the-list-api
---

Now that we have our basic homepage set up, let's make the API call to render our list of notes.

### Make the Request

{%change%} Add the following right below the state variable declarations in `src/containers/Home.js`.

``` javascript
useEffect(() => {
  async function onLoad() {
    if (!isAuthenticated) {
      return;
    }

    try {
      const notes = await loadNotes();
      setNotes(notes);
    } catch (e) {
      onError(e);
    }

    setIsLoading(false);
  }

  onLoad();
}, [isAuthenticated]);

function loadNotes() {
  return API.get("notes", "/notes");
}
```

We are using the [useEffect React Hook](https://reactjs.org/docs/hooks-effect.html). We covered how this works back in the [Load the State from the Session]({% link _chapters/load-the-state-from-the-session.md %}) chapter.

Let's quickly go over how we are using it here. We want to make a request to our `/notes` API to get the list of notes when our component first loads. But only if the user is authenticated. Since our hook relies on `isAuthenticated`, we need to pass it in as the second argument in the `useEffect` call as an element in the array. This is basically telling React that we only want to run our Hook again when the `isAuthenticated` value changes.

{%change%} And include our Amplify API module in the header.

``` javascript
import { API } from "aws-amplify";
```

Now let's render the results.

### Render the List

{%change%} Replace our `renderNotesList` placeholder method with the following.

``` coffee
function renderNotesList(notes) {
  return [{}].concat(notes).map((note, i) =>
    i !== 0 ? (
      <LinkContainer key={note.noteId} to={`/notes/${note.noteId}`}>
        <ListGroupItem header={note.content.trim().split("\n")[0]}>
          {"Created: " + new Date(note.createdAt).toLocaleString()}
        </ListGroupItem>
      </LinkContainer>
    ) : (
      <LinkContainer key="new" to="/notes/new">
        <ListGroupItem>
          <h4>
            <b>{"\uFF0B"}</b> Create a new note
          </h4>
        </ListGroupItem>
      </LinkContainer>
    )
  );
}
```

{%change%} Include the `LinkContainer` from `react-router-bootstrap`.

``` javascript
import { LinkContainer } from "react-router-bootstrap";
```

The code above does a few things.

1. It always renders a **Create a new note** button as the first item in the list (even if the list is empty). We do this by concatenating an array with an empty object with our `notes` array.

2. We render the first line of each note as the `ListGroupItem` header by doing `note.content.trim().split('\n')[0]`.

3. And the `LinkContainer` component directs our app to each of the items.

{%change%} Let's also add a couple of styles to our `src/containers/Home.css`.

``` css
.Home .notes h4 {
  font-family: "Open Sans", sans-serif;
  font-weight: 600;
  overflow: hidden;
  line-height: 1.5;
  white-space: nowrap;
  text-overflow: ellipsis;
}
.Home .notes p {
  color: #666;
}
```

Now head over to your browser and you should see your list displayed.

![Homepage list loaded screenshot](/assets/homepage-list-loaded.png)

If you click on each entry, the links should generate URLs with appropriate _noteIds_. For now, these URLs will take you to our 404 page.  We'll fix that in the next section.

Next up we are going to allow users to view and edit their notes.
