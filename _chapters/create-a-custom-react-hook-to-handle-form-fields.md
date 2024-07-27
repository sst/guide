---
layout: post
title: Create a Custom React Hook to Handle Form Fields
date: 2017-01-18 12:00:00
lang: en
ref: create-a-custom-react-hook-to-handle-form-fields
description: In this chapter we are going to create a custom React Hook to make it easier to handle form fields in our React app.
comments_id: create-a-custom-react-hook-to-handle-form-fields/1316
---

Now before we move on to creating our sign up page, we are going to take a short detour to simplify how we handle form fields in React. We built a form as a part of our login page and we are going to do the same for our sign up page. You'll recall that in our login component we were creating two state variables to store the username and password.

```typescript
const [email, setEmail] = useState("");
const [password, setPassword] = useState("");
```

And we also use something like this to set the state:

```tsx
onChange={(e) => setEmail(e.target.value)}
```

Now we are going to do something similar for our sign up page and it'll have a few more fields than the login page. So it makes sense to simplify this process and have some common logic that all our form related components can share. Plus this is a good way to introduce the biggest benefit of React Hooks — reusing stateful logic between components.

### Creating a Custom React Hook

{%change%} Add the following to `src/lib/hooksLib.ts`.

```typescript
import { useState, ChangeEvent, ChangeEventHandler } from "react";

interface FieldsType {
  [key: string | symbol]: string;
}

export function useFormFields(
  initialState: FieldsType
): [FieldsType, ChangeEventHandler] {
  const [fields, setValues] = useState(initialState);

  return [
    fields,
    function (event: ChangeEvent<HTMLInputElement>) {
      setValues({
        ...fields,
        [event.target.id]: event.target.value,
      });
      return;
    },
  ];
}
```

Creating a custom hook is amazingly simple. In fact, we did this back when we created our app context. But let's go over in detail how this works:

1. A custom React Hook starts with the word `use` in its name. So ours is called `useFormFields`.

2. Our Hook takes the initial state of our form fields as an object and saves it as a state variable called `fields`. The initial state in our case is an object where the _keys_ are the ids of the form fields and the _values_ are what the user enters.

3. So our hook returns an array with `fields` and a callback function that sets the new state based on the event object. The callback function takes the event object and gets the form field id from `event.target.id` and the value from `event.target.value`. In the case of our form elements, the `event.target.id` comes from the `controlId` that's set in the `Form.Group` element:

   ```tsx
   <Form.Group controlId="email">
     <Form.Label>Email</Form.Label>
     <Form.Control
       autoFocus
       type="email"
       value={email}
       onChange={(e) => setEmail(e.target.value)}
     />
   </Form.Group>
   ```

4. The callback function is directly using `setValues`, the function that we get from `useState`. So `onChange` we take what the user has entered and call `setValues` to update the state of `fields`, `{ ...fields, [event.target.id]: event.target.value }`. This updated object is now set as our new form field state.

And that's it! We can now use this in our Login component.

### Using Our Custom Hook

We need to make a couple of changes to the component to use our custom hook.

{%change%} Let's start by importing it in `src/containers/Login.tsx`.

```typescript
import { useFormFields } from "../lib/hooksLib";
```

{%change%} Replace the variable declarations.

```typescript
const [email, setEmail] = useState("");
const [password, setPassword] = useState("");
```

{%change%} With:

```typescript
const [fields, handleFieldChange] = useFormFields({
  email: "",
  password: "",
});
```

{%change%} Replace the `validateForm` function with.

```typescript
function validateForm() {
  return fields.email.length > 0 && fields.password.length > 0;
}
```

{%change%} In the `handleSubmit` function, replace the `Auth.signIn` call with.

```typescript
await Auth.signIn(fields.email, fields.password);
```

{%change%} Replace our two form fields, starting with the `<Form.Control type="email">`.

```tsx
<Form.Control
  autoFocus
  size="lg"
  type="email"
  value={fields.email}
  onChange={handleFieldChange}
/>
```

{%change%} And finally the password `<Form.Control type="password">`.

```tsx
<Form.Control
  size="lg"
  type="password"
  value={fields.password}
  onChange={handleFieldChange}
/>
```

You'll notice that we are using our `useFormFields` hook. A good way to think about custom React Hooks is to simply replace the line where we use it, with the Hook code itself. So instead of this line:

```typescript
const [fields, handleFieldChange] = useFormFields({
  email: "",
  password: "",
});
```

Simply imagine the code for the `useFormFields` function instead!

Finally, we are setting our fields using the function our custom hook is returning.

```tsx
onChange = { handleFieldChange }
```

Now we are ready to tackle our sign up page.
