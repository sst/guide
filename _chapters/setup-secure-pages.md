---
layout: post
title: Set up Secure Pages
date: 2017-02-01 00:00:00
lang: en
comments_id: set-up-secure-pages/42
ref: setup-secure-pages
---

We are almost done putting together our app. All the pages are done but there are a few pages that should not be accessible if a user is not logged in. For example, a page with the note should not load if a user is not logged in. Currently, we get an error when we do this. This is because the page loads and since there is no user in the session, the call to our API fails.

We also have a couple of pages that need to behave in sort of the same way. We want the user to be redirected to the homepage if they type in the login (`/login`) or signup (`/signup`) URL. Currently, the login and sign up page end up loading even though the user is already logged in.

There are many ways to solve the above problems. The simplest would be to just check the conditions in our containers and redirect. But since we have a few containers that need the same logic we can create a special route (like the `AppliedRoute` from the [Add the session to the state]({% link _chapters/add-the-session-to-the-state.md %}) chapter) for it.

We are going to create two different route components to fix the problem we have.

1. A route called the AuthenticatedRoute, that checks if the user is authenticated before routing.

2. And a component called the UnauthenticatedRoute, that ensures the user is not authenticated.

Let's create these components next.
