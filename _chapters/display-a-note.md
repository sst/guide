---
layout: post
title: Display a Note
date: 2017-01-28 00:00:00
lang: en
description: We want to create a page in our React.js app that will display a user’s note based on the id in the URL. We are going to use the React Router v6 Route component’s URL parameters to get the id. Using this id we are going to request our note from the serverless backend API. And use AWS Amplify's Storage.vault.get() method to get a secure link to download our attachment.
comments_id: display-a-note/112
ref: display-a-note
---

Now that we have a listing of all the notes, let's create a page that displays a note and lets the user edit it.

The first thing we are going to need to do is load the note when our container loads. Just like what we did in the `Home` container. So let's get started.

### Add the Route

Let's add a route for the note page that we are going to create.

{%change%} Add the following line to `src/Routes.js` **below** our `/notes/new` route.

```jsx
<Route path="/notes/:id" element={<Notes />} />
```

This is important because we are going to be pattern matching to extract our note id from the URL.

By using the route path `/notes/:id` we are telling the router to send all matching routes to our component `Notes`. This will also end up matching the route `/notes/new` with an `id` of `new`. To ensure that doesn't happen, we put our `/notes/new` route before the pattern matching one.

{%change%} And include our component in the header.

```js
import Notes from "./containers/Notes";
```

Of course this component doesn't exist yet and we are going to create it now.

### Add the Container

{%change%} Create a new file `src/containers/Notes.js` and add the following.

```jsx
import React, { useRef, useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { API, Storage } from "aws-amplify";
import { onError } from "../lib/errorLib";

export default function Notes() {
  const file = useRef(null);
  const { id } = useParams();
  const nav = useNavigate();
  const [note, setNote] = useState(null);
  const [content, setContent] = useState("");

  useEffect(() => {
    function loadNote() {
      return API.get("notes", `/notes/${id}`);
    }

    async function onLoad() {
      try {
        const note = await loadNote();
        const { content, attachment } = note;

        if (attachment) {
          note.attachmentURL = await Storage.vault.get(attachment);
        }

        setContent(content);
        setNote(note);
      } catch (e) {
        onError(e);
      }
    }

    onLoad();
  }, [id]);

  return <div className="Notes"></div>;
}
```

We are doing a couple of things here.

1. We are using the `useEffect` Hook to load the note when our component first loads. We then save it to the state. We get the `id` of our note from the URL using `useParams` hook that comes with React Router. The `id` is a part of the pattern matching in our route (`/notes/:id`).

2. If there is an attachment, we use the key to get a secure link to the file we uploaded to S3. We then store this in the new note object as `note.attachmentURL`.

3. The reason why we have the `note` object in the state along with the `content` and the `attachmentURL` is because we will be using this later when the user edits the note.

Now if you switch over to your browser and navigate to a note that we previously created, you'll notice that the page renders an empty container.

![Empty notes page loaded screenshot](/assets/empty-notes-page-loaded.png)

Next up, we are going to render the note we just loaded.
