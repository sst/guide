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

``` javascript
const [email, setEmail] = useState("");
const [password, setPassword] = useState("");
```

And we also use something like this to set the state:

``` coffee
onChange={(e) => setEmail(e.target.value)}
```

Now we are going to do something similar for our sign up page and it'll have a few more fields than the login page. So it makes sense to simplify this process and have some common logic that all our form related components can share. Plus this is a good way to introduce the biggest benefit of React Hooks — reusing stateful logic between components.

### Creating a Custom React Hook

{%change%} Add the following to `src/libs/hooksLib.js`.

``` javascript
import { useState } from "react";

export function useFormFields(initialState) {
  const [fields, setValues] = useState(initialState);

  return [
    fields,
    function(event) {
      setValues({
        ...fields,
        [event.target.id]: event.target.value
      });
    }
  ];
}
```

Creating a custom hook is amazingly simple. In fact, we did this back when we created our app context. But let's go over in detail how this works:

1. A custom React Hook starts with the word `use` in its name. So ours is called `useFormFields`.

2. Our Hook takes the initial state of our form fields as an object and saves it as a state variable called `fields`. The initial state in our case is an object where the _keys_ are the ids of the form fields and the _values_ are what the user enters.

3. So our hook returns an array with `fields` and a callback function that sets the new state based on the event object. The callback function takes the event object and gets the form field id from `event.target.id` and the value from `event.target.value`. In the case of our form the elements, the `event.target.id` comes from the `controlId` thats set in the `Form.Group` element:

   ``` coffee
   <Form.Group size="lg" controlId="email">
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

{%change%} Replace our `src/containers/Login.js` with the following:

``` coffee
import React, { useState } from "react";
import { Auth } from "aws-amplify";
import Form from "react-bootstrap/Form";
import { useHistory } from "react-router-dom";
import LoaderButton from "../components/LoaderButton";
import { useAppContext } from "../libs/contextLib";
import { useFormFields } from "../libs/hooksLib";
import { onError } from "../libs/errorLib";
import "./Login.css";

export default function Login() {
  const history = useHistory();
  const { userHasAuthenticated } = useAppContext();
  const [isLoading, setIsLoading] = useState(false);
  const [fields, handleFieldChange] = useFormFields({
    email: "",
    password: ""
  });

  function validateForm() {
    return fields.email.length > 0 && fields.password.length > 0;
  }

  async function handleSubmit(event) {
    event.preventDefault();

    setIsLoading(true);

    try {
      await Auth.signIn(fields.email, fields.password);
      userHasAuthenticated(true);
      history.push("/");
    } catch (e) {
      onError(e);
      setIsLoading(false);
    }
  }

  return (
    <div className="Login">
      <Form onSubmit={handleSubmit}>
        <Form.Group size="lg" controlId="email">
          <Form.Label>Email</Form.Label>
          <Form.Control
            autoFocus
            type="email"
            value={fields.email}
            onChange={handleFieldChange}
          />
        </Form.Group>
        <Form.Group size="lg" controlId="password">
          <Form.Label>Password</Form.Label>
          <Form.Control
            type="password"
            value={fields.password}
            onChange={handleFieldChange}
          />
        </Form.Group>
        <LoaderButton
          block
          size="lg"
          type="submit"
          isLoading={isLoading}
          disabled={!validateForm()}
        >
          Login
        </LoaderButton>
      </Form>
    </div>
  );
}
```

You'll notice that we are using our `useFormFields` Hook. A good way to think about custom React Hooks is to simply replace the line where we use it, with the Hook code itself. So instead of this line:

``` javascript
const [fields, handleFieldChange] = useFormFields({
  email: "",
  password: ""
});
```

Simply imagine the code for the `useFormFields` function instead!

Finally, we are setting our fields using the function our custom Hook is returning.

``` coffee
onChange={handleFieldChange}
```

Now we are ready to tackle our sign up page.
