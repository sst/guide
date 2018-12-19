---
layout: post
title: DynamoDB Paging
date: 2016-12-30 00:00:00
description: 
context: true
code: backend
comments_id: add-a-create-note-api/125
---

For the [notes app](https://demo.serverless-stack.com) that we have created, we allow our users to see a list of all the notes they have. But we left out a detail that needs to be handled when a user has a lot of notes. DynamoDB by default returns the amount of results that can fit in 1MB. So in this case where the number of notes exceeds the 1MB query result size, we need to be able to page through the rest of the notes.

In this chapter we are going to look at how to add paging to DynamoDB tables and how to use that in your React app.

The version of the notes app used in this chapter:

- Has a separate GitHub repository for the Serverless backend app:
- A separate GitHub repository for the React frontend app:
- And a hosted version here: 

Let's get started by understanding how DynamoDB handles pagination.

### Paging in DynamoDB

DynamoDB handles paging in a very simple way:

- Firstly, you can apply paging for both `Query` and `Scan` operations in DynamoDB. And you can specify page size by passing in `Limit`.
- If there are more items beyong the page size, the results will include a `LastEvaluatedKey` indicating the index key of the last item that was returned.
- And if you make the same query and pass in the key as `ExclusiveStartKey`, you will get the next page of items.
- And finally, if the `Limit` is not passed in, the default page size is 1MB. Ie, how many ever items that fit into 1MB.

Now that we have a good idea of how paging works, let's move on to implementing it in our Serverless backend API.

### Handle Paging in a Lambda Function

Working off of our Lambda function that gets the list of a user's notes, we are going to add the ability to page through them.

<img class="code-marker" src="/assets/s.png" />Replace `list.js` with the following.

``` javascript
import * as dynamoDbLib from "./libs/dynamodb-lib";
import { success, failure } from "./libs/response-lib";

export async function main(event, context) {
  const startKey = event.paging_token
    ? JSON.parse(event.paging_token)
    : undefined;

  const params = {
    TableName: "notes",
    KeyConditionExpression: "userId = :userId",
    ExpressionAttributeValues: {
      ":userId": event.requestContext.identity.cognitoIdentityId
    },
    ExclusiveStartKey: startKey,
    Limit: 10,
  };

  try {
    const result = await dynamoDbLib.call("query", params);
    return success({
      items: result.Items,
      paging_token: result.LastEvaluatedKey ? JSON.stringify(result.LastEvaluatedKey) : undefined,
    });
  } catch (e) {
    return failure({ status: false });
  }
}
```

This should be pretty straightforward:

- We look for the `paging_token` querystring variable.
- If it is available, we JSON parse it and set it as the `ExclusiveStartKey` in our query params. If it isn't available, we leave it as `undefined`.
- We make the query by setting the page size we want as the `Limit`. In this case we are setting it to 10. Alternatively, you can let the frontend specify this.
- After we make the query we check if the `LastEvaluatedKey` is set in the results. If it's set, this means that there are more than one page of results. We then JSON encode it, set it as the `paging_token`, and return it as a part of the response.
- This `paging_token` is what the frontend will return back to us when we want to display the next page of results.

Next let's look at the changes that we need to make on the frontend.

### Add a Load More Button

If you've followed through the backend portion, it should be clear that the frontend is only responsbile for getting the `paging_token` from the API response. And making the request to get the next page, with the `paging_token` set.

<img class="code-marker" src="/assets/s.png" />Replace the `src/containers/Home.js` with the following.

``` javascript
import React, { Component } from "react";
import { API } from "aws-amplify";
import { Link } from "react-router-dom";
import { LinkContainer } from "react-router-bootstrap";
import { Button, PageHeader, ListGroup, ListGroupItem } from "react-bootstrap";
import "./Home.css";

export default class Home extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isLoading: true,
      isLoadingMore: false,
      notes: [],
      pagingToken: undefined,
      hasMore: false,
    };
  }

  async componentDidMount() {
    if (!this.props.isAuthenticated) {
      return;
    }

    try {
      await this.notes(true);
    } catch (e) {
      alert(e);
    }

    this.setState({ isLoading: false });
  }

  async notes(isFirstPage) {
    if ( ! isFirstPage) {
      this.setState({ isLoadingMore: true });
    }

    const notes = await API.get("notes", "/notes", {
      paging_token : this.state.pagingToken
    });
    this.setState({
      notes: notes.items,
      pagingToken: notes.paging_token,
      hasMore: notes.paging_token !== undefined,
    });

    if ( ! isFirstPage) {
      this.setState({ isLoadingMore: false });
    }
  }

  async loadMore() {

    await this.notes();

    this.setState({ isLoadingMore: false });
  }

  renderNotesList(notes) {
    return [{}].concat(notes).map(
      (note, i) =>
        i !== 0
          ? <LinkContainer
              key={note.noteId}
              to={`/notes/${note.noteId}`}
            >
              <ListGroupItem header={note.content.trim().split("\n")[0]}>
                {"Created: " + new Date(note.createdAt).toLocaleString()}
              </ListGroupItem>
            </LinkContainer>
          : <LinkContainer
              key="new"
              to="/notes/new"
            >
              <ListGroupItem>
                <h4>
                  <b>{"\uFF0B"}</b> Create a new note
                </h4>
              </ListGroupItem>
            </LinkContainer>
    );
  }

  renderLander() {
    return (
      <div className="lander">
        <h1>Scratch</h1>
        <p>A simple note taking app</p>
        <div>
          <Link to="/login" className="btn btn-info btn-lg">
            Login
          </Link>
          <Link to="/signup" className="btn btn-success btn-lg">
            Signup
          </Link>
        </div>
      </div>
    );
  }

  renderNotes() {
    return (
      <div className="notes">
        <PageHeader>Your Notes</PageHeader>
        <ListGroup>
          {!this.state.isLoading && this.renderNotesList(this.state.notes)}
        </ListGroup>
        { this.state.hasMore &&
          <Button
            disabled={ this.state.isLoadingMore }
            onClick={ notes }>
            Load More
          </Button>
        }
      </div>
    );
  }

  render() {
    return (
      <div className="Home">
        {this.props.isAuthenticated ? this.renderNotes() : this.renderLander()}
      </div>
    );
  }
}
```

Let's quickly go over what we are doing here:
- 
- 

Now you should be able to click the _Load More_ button to page through all the notes for that user.

