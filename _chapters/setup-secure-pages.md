---
layout: post
title: Setup Secure Pages
date: 2017-02-01 00:00:00
---

We are almost done putting together our app. All the pages are done but there are a few pages that should not be accessible if a user is not logged in. For example, a page with the note should not load if a user is not logged in. Currently, we get an error when we do this. This is because the page loads and since the user token does not exist, the call to our API fails.

We also have a couple of pages that need to behave in sort of the same way. We want the user to be redirected to the home page if they type in the login (`/login`) or signup (`/signup`) URL. Currently, the login and sign up page end up loading even though the user is logged in.

There are many ways to solve the above problems. The simplest would be to just check the conditions in our containers and redirect. But since we have a few containers that need the same logic we can create a [High-Order Component](https://facebook.github.io/react/docs/higher-order-components.html) (or HOC) for it. A HOC is a function that takes a component and returns a component. We are going to create two different components to fix the problem we have.

1. A component called the AuthenticatedComponent, that checks if the user is authenticated before proceeding.

2. And a component called the UnauthenticatedComponent, that ensures the user is not authenticated.

Let's create these components next.
