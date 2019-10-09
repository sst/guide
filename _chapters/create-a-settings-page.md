---
layout: post
title: Create a Settings Page
date: 2017-01-31 06:00:00
lang: en
description: Our notes app needs a settings page for our users to input their credit card details and sign up for a pricing plan.
context: true
ref: create-a-settings-page
comments_id: create-a-settings-page/184
---

We are going to add a settings page to our app. This is going to allow users to pay for our service. The flow will look something like this:

1. Users put in their credit card info and the number of notes they want to store.
2. We call Stripe on the frontend to generate a token for the credit card.
3. We then call our billing API with the token and the number of notes.
4. Our billing API calculates the amount and bills the card!

To get started let's add our settings page.

<img class="code-marker" src="/assets/s.png" />Create a new file in `src/containers/Settings.js` and add the following.

``` coffee
import React, { useState } from "react";
import { API } from "aws-amplify";

export default function Settings(props) {
  const [isLoading, setIsLoading] = useState(false);

  function billUser(details) {
    return API.post("notes", "/billing", {
      body: details
    });
  }

  return (
    <div className="Settings">
    </div>
  );
}
```

<img class="code-marker" src="/assets/s.png" />Next import this component in the header of `src/Routes.js`.

``` js
import Settings from "./containers/Settings";
```

<img class="code-marker" src="/assets/s.png" />Add the following below the `/signup` route in our `<Switch>` block in `src/Routes.js`.

``` coffee
<AppliedRoute path="/settings" exact component={Settings} appProps={appProps} />
```

<img class="code-marker" src="/assets/s.png" />Next add a link to our settings page in the navbar by replacing the `return` statement in `src/App.js` with this.

{% raw %}
``` coffee
return (
  !isAuthenticating && (
    <div className="App container">
      <Navbar fluid collapseOnSelect>
        <Navbar.Header>
          <Navbar.Brand>
            <Link to="/">Scratch</Link>
          </Navbar.Brand>
          <Navbar.Toggle />
        </Navbar.Header>
        <Navbar.Collapse>
          <Nav pullRight>
            {isAuthenticated ? (
              <>
                <LinkContainer to="/settings">
                  <NavItem>Settings</NavItem>
                </LinkContainer>
                <NavItem onClick={handleLogout}>Logout</NavItem>
              </>
            ) : (
              <>
                <LinkContainer to="/signup">
                  <NavItem>Signup</NavItem>
                </LinkContainer>
                <LinkContainer to="/login">
                  <NavItem>Login</NavItem>
                </LinkContainer>
              </>
            )}
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <Routes appProps={{ isAuthenticated, userHasAuthenticated }} />
    </div>
  )
);
```
{% endraw %}

You'll notice that we added another link in the navbar that only displays when a user is logged in.

Now if you head over to your app, you'll see a new **Settings** link at the top. Of course, the page is pretty empty right now.

![Add empty settings page screenshot](/assets/part2/add-empty-settings-page.png)

Next, we'll add our Stripe SDK keys to our config.
