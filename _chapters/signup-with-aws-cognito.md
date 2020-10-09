---
layout: post
title: Signup with AWS Cognito
date: 2017-01-21 00:00:00
lang: en
ref: signup-with-aws-cognito
description: To implement a signup form in our React.js app using Amazon Cognito we are going to use AWS Amplify. We are going to call the Auth.signUp() method to sign a user up and call the Auth.confirmSignUp() method with the confirmation code to complete the process.
comments_id: signup-with-aws-cognito/130
---

Now let's go ahead and implement the `handleSubmit` and `handleConfirmationSubmit` functions and connect it up with our AWS Cognito setup.

{%change%} Replace our `handleSubmit` and `handleConfirmationSubmit` functions in `src/containers/Signup.js` with the following.

``` javascript
async function handleSubmit(event) {
  event.preventDefault();

  setIsLoading(true);

  try {
    const newUser = await Auth.signUp({
      username: fields.email,
      password: fields.password,
    });
    setIsLoading(false);
    setNewUser(newUser);
  } catch (e) {
    onError(e);
    setIsLoading(false);
  }
}

async function handleConfirmationSubmit(event) {
  event.preventDefault();

  setIsLoading(true);

  try {
    await Auth.confirmSignUp(fields.email, fields.confirmationCode);
    await Auth.signIn(fields.email, fields.password);

    userHasAuthenticated(true);
    history.push("/");
  } catch (e) {
    onError(e);
    setIsLoading(false);
  }
}
```

{%change%} Also, include the Amplify Auth in our header.

``` javascript
import { Auth } from "aws-amplify";
```

The flow here is pretty simple:

1. In `handleSubmit` we make a call to signup a user. This creates a new user object.

2. Save that user object to the state using `setNewUser`.

3. In `handleConfirmationSubmit` use the confirmation code to confirm the user.

4. With the user now confirmed, Cognito now knows that we have a new user that can login to our app.

5. Use the email and password to authenticate exactly the same way we did in the login page.

6. Update the App's context using the `userHasAuthenticated` function.

7. Finally, redirect to the homepage.

Now if you were to switch over to your browser and try signing up for a new account it should redirect you to the homepage after sign up successfully completes.

![Redirect home after signup screenshot](/assets/redirect-home-after-signup.png)

A quick note on the signup flow here. If the user refreshes their page at the confirm step, they won't be able to get back and confirm that account. It forces them to create a new account instead. We are keeping things intentionally simple but here are a couple of hints on how to fix it.

1. Check for the `UsernameExistsException` in the `handleSubmit` function's `catch` block.

2. Use the `Auth.resendSignUp()` method to resend the code if the user has not been previously confirmed. Here is a link to the [Amplify API docs](https://aws.github.io/aws-amplify/api/classes/authclass.html#resendsignup).

3. Confirm the code just as we did before.

Give this a try and post in the comments if you have any questions.

Now while developing you might run into cases where you need to manually confirm an unauthenticated user. You can do that with the AWS CLI using the following command.

```bash
aws cognito-idp admin-confirm-sign-up \
   --region YOUR_COGNITO_REGION \
   --user-pool-id YOUR_COGNITO_USER_POOL_ID \
   --username YOUR_USER_EMAIL
```

Just be sure to use your Cognito User Pool Id and the email you used to create the account.

If you would like to allow your users to change their email or password, you can refer to our [Extra Credit series of chapters on user management]({% link _chapters/manage-user-accounts-in-aws-amplify.md %}).

Next up, we are going to create our first note.
