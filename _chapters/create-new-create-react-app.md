---
layout: post
title: Create a new app with Create React App
---

Let's get started by creating our single page app using React. We'll use the [Create React App](https://github.com/facebookincubator/create-react-app) project to set everything up. It is officially supported by the React team and conviniently packages all the dependencies for a React.js proejct.

From your working directory, run the following commands to create our note taking app.

{% highlight bash %}
create-react-app note-app
{% endhighlight %}

This should take a second to run, and it will create your new project.

{% highlight bash %}
cd note-app
npm start
{% endhighlight %}

This should fire up the newly created app in your browser.

![New Create React App screenshot]({{ site.url }}/assets/new-create-react-app.png)

Create React App comes with pre-loaded with a pretty convinient yet minimal developement environment. It includes live reloading, a testing framework, ES6 support, and [much more](https://github.com/facebookincubator/create-react-app#why-use-this).

We still need to add a couple of more things before we are ready to work on our note taking app.
