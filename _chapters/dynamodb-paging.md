---
layout: post
title: DynamoDB Paging
date: 2016-12-30 00:00:00
description: To allow users to create notes in our note taking app, we are going to add a create note POST API. To do this we are going to add a new Lambda function to our Serverless Framework project. The Lambda function will save the note to our DynamoDB table and return the newly created note. We also need to ensure to set the Access-Control headers to enable CORS for our serverless backend API.
context: true
code: backend
comments_id: add-a-create-note-api/125
---

- Can apply paging for both 'Query' and 'Scan' operations
- You can specify page size by passing in 'Limit'
- If there are more items beyong the page size, the results will include 'LastEvaluatedKey' indicating the index key of the last item it returned.
- If you make the same query/scan and pass in the key as 'ExclusiveStartKey', you will get the next page of items
- If 'Limit' is not passed in, the default page size is 1MB (how many ever items that fit into 1MB)

### Backend

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
  };

  try {
    const result = await dynamoDbLib.call("query", params);
    // Return the matching list of items in response body
    return success({
      items: result.Items,
      paging_token: result.LastEvaluatedKey ? JSON.stringify(result.LastEvaluatedKey) : undefined,
    });
  } catch (e) {
    return failure({ status: false });
  }
}
```

### Frontend

Store the paging token in the state

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
