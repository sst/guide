---
layout: post
title: Login with AWS Cognito
---

Before we link up our login form with our AWS Cognito setup let's grab our Cognito details and load it into our application as a part of it's config.

### Load AWS Cognito Details

We'll take our Cognito **User Pool Id** and our **Client Id** and save into it `src/config.js` using the following.

{% highlight javascript %}
export default {
  cognito: {
    USER_POOL_ID : 'us-east-1_exampleid',
    CLIENT_ID : '12sr50exampleclientid',
  }
};
{% endhighlight %}

And to load it into our login form simply import it by adding the following to the header of our `Login` container.

{% highlight javascript %}
import config from '../config.js';
{% endhighlight %}

### Login to AWS Cognito

We are going to use the NPM module `amazon-cognito-identity-js` to login to Cognito. Install it by running the following in your project root.

{% highlight bash %}
npm install amazon-cognito-identity-js --save
{% endhighlight %}

And include the following in the header of our `Login` container.

{% highlight javascript %}
import {
  CognitoUserPool,
  AuthenticationDetails,
  CognitoUser
} from 'amazon-cognito-identity-js';
{% endhighlight %}

The actual login code is relatively simple. Add the following method to your `Login` container as well.

{% highlight javascript %}
login(username, password) {
  const userPool = new CognitoUserPool({
    UserPoolId: config.cognito.USER_POOL_ID,
    ClientId: config.cognito.CLIENT_ID
  });
  const authenticationData = {
    Username: username,
    Password: password
  };

  const user = new CognitoUser({ Username: username, Pool: userPool });
  const authenticationDetails = new AuthenticationDetails(authenticationData);

  return new Promise((resolve, reject) => (
    user.authenticateUser(authenticationDetails, {
      onSuccess: (result) => resolve(result.getIdToken().getJwtToken()),
      onFailure: (err) => reject(err),
    })
  ));
}
{% endhighlight %}

This function does a few things for us:

1. It creates a new `CognitoUserPool` using the details from our config. And it creates a new `CognitoUser` using the username that is passed in.

2. It then authenticates our user using the authentication details with the call `user.authenticateUser`. If the authentication call is successful we can retreive a **user token** that we can then use for our subsequent API calls.

3. Since, the login call is asynchronous we return a `Promise` object. This way we can call this method directly and simply get the user token in return without fidgeting with callbacks.

### Trigger Login onSubmit

To connect the above `login` method to our form simply replace our placeholder `handleSubmit` method with the following.

{% highlight javascript %}
handleSubmit = async (event) => {
  event.preventDefault();

  try {
    const userToken = await this.login(this.state.username, this.state.password);
    alert(userToken);
  }
  catch(e) {
    alert(e);
  }
}
{% endhighlight %}

We are doing two things of note here.

1. We grab the `username` and `password` from `this.state` and call our `login` method with it.

2. We use the `await` keyword to invoke the `login` method and store the userToken that it returns. And to do so we need to label our `handleSubmit` method as `async`.

Now if you were to try to login using our admin user, you should see the browser alert with the newly created user token.

![Login success screenshot]({{ site.url }}/assets/login-success.png)

Next, we'll take a look at storing this user token in our app.
