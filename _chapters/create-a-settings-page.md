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

{%change%} Create a new file in `src/types/billing.ts` and add the following to define a type for our billing API.

```typescript
export interface BillingType {
  storage: string;
  source?: string;
}
```

{%change%} Create a new file in `src/containers/Settings.tsx` and add the following.

```tsx
import { useState } from "react";
import config from "../config";
import { API } from "aws-amplify";
import { onError } from "../lib/errorLib";
import { useNavigate } from "react-router-dom";
import { BillingType } from "../types/billing";

export default function Settings() {
  const nav = useNavigate();
  const [isLoading, setIsLoading] = useState(false);

  function billUser(details: BillingType) {
    return API.post("notes", "/billing", {
      body: details,
    });
  }

  return <div className="Settings"></div>;
}
```

{%change%} Next, add the following below the `/signup` route in our `<Routes>` block in `src/Routes.tsx`.

```tsx
<Route path="/settings" element={<Settings />} />
```

{%change%} And import this component in the header of `src/Routes.js`.

```tsx
import Settings from "./containers/Settings.tsx";
```

Next add a link to our settings page in the navbar.

{%change%} Replace the following line in the `return` statement `src/App.tsx`.

```tsx
<Nav.Link onClick={handleLogout}>Logout</Nav.Link>
```

{%change%} With.

```tsx
<>
  <LinkContainer to="/settings">
    <Nav.Link>Settings</Nav.Link>
  </LinkContainer>
  <Nav.Link onClick={handleLogout}>Logout</Nav.Link>
</>
```

Now if you head over to your app, you'll see a new **Settings** link at the top. Of course, the page is pretty empty right now.

![Add empty settings page screenshot](/assets/part2/add-empty-settings-page.png)

Next, we'll add our Stripe SDK keys to our config.
