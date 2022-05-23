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

```js
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

```js
import { API } from "aws-amplify";
```

Now let's render the results.

### Render the List

{%change%} Replace our `renderNotesList` placeholder method with the following.

```jsx
function renderNotesList(notes) {
  return (
    <>
      <LinkContainer to="/notes/new">
        <ListGroup.Item action className="py-3 text-nowrap text-truncate">
          <BsPencilSquare size={17} />
          <span className="ml-2 font-weight-bold">Create a new note</span>
        </ListGroup.Item>
      </LinkContainer>
      {notes.map(({ noteId, content, createdAt }) => (
        <LinkContainer key={noteId} to={`/notes/${noteId}`}>
          <ListGroup.Item action>
            <span className="font-weight-bold">
              {content.trim().split("\n")[0]}
            </span>
            <br />
            <span className="text-muted">
              Created: {new Date(createdAt).toLocaleString()}
            </span>
          </ListGroup.Item>
        </LinkContainer>
      ))}
    </>
  );
}
```

The code above does a few things.

1. It always renders a **Create a new note** button as the first item in the list (even if the list is empty). And it links to [the create note page that we previously created]({% link _chapters/add-the-create-note-page.md %}).

   ```jsx
   <LinkContainer to="/notes/new">
     <ListGroup.Item action className="py-3 text-nowrap text-truncate">
       <BsPencilSquare size={17} />
       <span className="ml-2 font-weight-bold">Create a new note</span>
     </ListGroup.Item>
   </LinkContainer>
   ```

2. In the button we use a `BsPencilSquare` icon from the [React Icons Bootstrap icon set](https://react-icons.github.io/icons?name=bs).

3. We then render a list of all the notes.

   ```js
   notes.map(({ noteId, content, createdAt }) => (...
   ```

4. The first line of each note's content is set as the `ListGroup.Item` header.

   ```js
   note.content.trim().split("\n")[0];
   ```

5. And we convert the date the note was created to a more friendly format.

   ```js
   {
     new Date(createdAt).toLocaleString();
   }
   ```

6. The `LinkContainer` component directs our app to each of the items.

{%change%} Include the `LinkContainer` and `BsPencilSquare` icon at the top of `src/containers/Home.js`.

```js
import { BsPencilSquare } from "react-icons/bs";
import { LinkContainer } from "react-router-bootstrap";
```

Now head over to your browser and you should see your list displayed.

![Homepage list loaded screenshot](/assets/homepage-list-loaded.png)

If you click on each entry, the links should generate URLs with appropriate _noteIds_. For now, these URLs will take you to our 404 page. We'll fix that in the next section.

Next up we are going to allow users to view and edit their notes.
