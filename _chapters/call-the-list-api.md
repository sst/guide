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

{%change%} Replace the notes/setNotes state variable declaration line with this line in Home.tsx

```tsx
const [notes, setNotes] = useState<Array<NotesType>>([]);
```

{%change%} Add the following right below the state variable declarations at the top of the **Home** function in `src/containers/Home.tsx`.

```tsx
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
  return API.get("notes", "/notes", {});
}
```

We are using the [useEffect React Hook](https://reactjs.org/docs/hooks-effect.html){:target="_blank"}. We covered how this works back in the [Load the State from the Session]({% link _chapters/load-the-state-from-the-session.md %}){:target="_blank"} chapter.

Let's quickly go over how we are using it here. We want to make a request to our `/notes` API to get the list of notes when our component first loads. But only if the user is authenticated. Since our hook relies on `isAuthenticated`, we need to pass it in as the second argument in the `useEffect` call as an element in the array. This is basically telling React that we only want to run our Hook again when the `isAuthenticated` value changes.

{%change%} Add `useEffect` into the import from react

```tsx
import React, {useEffect, useState} from "react";
```

{%change%} And include our Amplify API module, NotesLib, and ErrorLib in the header.

```tsx
import { API } from "aws-amplify";
import {onError} from "../lib/errorLib";
import {NotesType} from "../lib/notesLib";
```

Now let's render the results.

### Render the List

{%change%} Replace our `renderNotesList` placeholder method with the following.

```tsx
function formatShortenedNote(str: string | undefined) {
  if (!str) {
    return "Empty Note"
  }

  return str.trim().split("\n")[0]
}

function formatCreatedAt(str: undefined | string | Date | number) {
  if (!str) {
    return ""
  }

  return new Date(str).toLocaleString()
}

function renderNotesList(notes: NotesType[]) {
  return (
    <>
      <LinkContainer to="/notes/new">
        <ListGroup.Item action className="py-3 text-nowrap text-truncate">
          <BsPencilSquare size={17} />
          <span className="ms-2 fw-bold">Create a new note</span>
        </ListGroup.Item>
      </LinkContainer>
      {notes.map(({ noteId, content, createdAt }) => (
        <LinkContainer key={noteId} to={`/notes/${noteId}`}>
          <ListGroup.Item action className="text-nowrap text-truncate">
            <span className="fw-bold">{formatShortenedNote(content)}</span>
            <br />
            <span className="text-muted">
              Created: {formatCreatedAt(createdAt)}
            </span>
          </ListGroup.Item>
        </LinkContainer>
      ))}
    </>
  );
}
```

{%change%} And include the `LinkContainer` and `BsPencilSquare` icon at the top of `src/containers/Home.tsx`.

```tsx
import { BsPencilSquare } from "react-icons/bs";
import { LinkContainer } from "react-router-bootstrap";
```

The code above does a few things.

1. It always renders a **Create a new note** button as the first item in the list (even if the list is empty). And it links to [the create note page that we previously created]({% link _chapters/add-the-create-note-page.md %}).

   ```tsx
   <LinkContainer to="/notes/new">
     <ListGroup.Item action className="py-3 text-nowrap text-truncate">
       <BsPencilSquare size={17} />
       <span className="ms-2 fw-bold">Create a new note</span>
     </ListGroup.Item>
   </LinkContainer>
   ```

2. In the button we use a `BsPencilSquare` icon from the [React Icons Bootstrap icon set](https://react-icons.github.io/icons?name=bs).

3. We then render a list of all the notes.

   ```tsx
   notes.map(({ noteId, content, createdAt }) => (...
   ```

4. The first line of each note's content is set as the `ListGroup.Item` header.

   ```tsx
   function formatCreatedAt(str: undefined | string | Date | number) {
    if (!str) {
      return "Empty Note"
    }
    
    return new Date(str).toLocaleString()
    }
   ```

5. And we safely convert the date the note was created to a more friendly format.

   ```tsx
   function formatCreatedAt(str: undefined | string | Date | number) {
     if (!str) {
       return ""
     }
    
     return new Date(str).toLocaleString()
   }
   ```

6. The `LinkContainer` component directs our app to each of the items.



Now head over to your browser and you should see your list displayed.

![Homepage list loaded screenshot](/assets/homepage-list-loaded.png)

If you click on each entry, the links should generate URLs with appropriate _noteIds_. For now, these URLs will take you to our 404 page. We'll fix that in the next section.

Next up we are going to allow users to view and edit their notes.
