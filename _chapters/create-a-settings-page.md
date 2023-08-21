---
layout: post
title: Create a Settings Page
date: 2017-01-31 06:00:00
lang: en
description: Our notes app needs a settings page for our users to input their credit card details and sign up for a pricing plan.
ref: create-a-settings-page
comments_id: create-a-settings-page/184
---

We are going to add a settings page to our app. This is going to allow users to pay for our service. The flow will look something like this:

1. Users put in their credit card info and the number of notes they want to store.
2. We call Stripe on the frontend to generate a token for the credit card.
3. We then call our billing API with the token and the number of notes.
4. Our billing API calculates the amount and bills the card!

To get started let's add our settings page.

{%change%} Create a new file in `src/lib/billingLib.ts` and add the following to define our `BillingDetailsType`.

```typescript
export interface BillingDetailsType {
  [key: string | symbol]: any;
}

```

{%change%} Create a new file in `src/containers/Settings.tsx` and add the following.

```tsx
import React, { useState } from "react";
import { API } from "aws-amplify";
import { useNavigate } from "react-router-dom";
import {BillingDetailsType} from "../lib/billingLib";
import { onError } from "../lib/errorLib";
import config from "../config";

export default function Settings() {
  const nav = useNavigate();
  const [isLoading, setIsLoading] = useState(false);

  function billUser(details: BillingDetailsType) {
    return API.post("notes", "/billing", {
      body: details,
    });
  }

  return <div className="Settings"></div>;
}
```

{%change%} Next, add the following below the `/signup` route in our `<Routes>` block in `src/Routes.js`.

```tsx
<Route path="/settings" element={<Settings />} />
```

{%change%} And import this component in the header of `src/Routes.js`.

```tsx
import Settings from "./containers/Settings";
```


{%change%} Next add a link to our settings page in the navbar by replacing the `return` statement in the `authenticationComplete` function within `src/App.tsx` with this.

{% raw %}

```tsx
return (
    <div className="App container py-3">
      <Navbar collapseOnSelect bg="light" expand="md" className="mb-3 px-3">
        <LinkContainer to="/">
          <Navbar.Brand className="fw-bold text-muted">Scratch</Navbar.Brand>
        </LinkContainer>
        <Navbar.Toggle />
        <Navbar.Collapse className="justify-content-end">
          <Nav activeKey={window.location.pathname}>
            {isAuthenticated ? (
              <>
                <LinkContainer to="/settings">
                  <Nav.Link>Settings</Nav.Link>
                </LinkContainer>
                <Nav.Link onClick={handleLogout}>Logout</Nav.Link>
              </>
            ) : (
              <>
                <LinkContainer to="/signup">
                  <Nav.Link>Signup</Nav.Link>
                </LinkContainer>
                <LinkContainer to="/login">
                  <Nav.Link>Login</Nav.Link>
                </LinkContainer>
              </>
            )}
          </Nav>
        </Navbar.Collapse>
      </Navbar>
      <AppContext.Provider value={{ isAuthenticated, userHasAuthenticated } as AppContextType}>
        <Routes />
      </AppContext.Provider>
    </div>
);
```

{% endraw %}

You'll notice that we added another link in the navbar that only displays when a user is logged in.

```tsx
<LinkContainer to="/settings">
  <Nav.Link>Settings</Nav.Link>
</LinkContainer>
```

Now if you head over to your app, you'll see a new **Settings** link at the top. Of course, the page is pretty empty right now.

![Add empty settings page screenshot](/assets/part2/add-empty-settings-page.png)

Next, we'll add our Stripe SDK keys to our config.
