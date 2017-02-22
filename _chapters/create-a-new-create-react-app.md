---
layout: post
title: Create a new app with Create React App
date: 2017-01-06 00:00:00
---

Let's get started by creating our single page app using React. We'll use the [Create React App](https://github.com/facebookincubator/create-react-app) project to set everything up. It is officially supported by the React team and conviniently packages all the dependencies for a React.js proejct.

### Install Create React App

Run the following command in your working directory

{% highlight bash %}
npm install -g create-react-app
{% endhighlight %}

This installs the NPM package globally.

### Create a new app

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

### Change the title

Let's quickly change the title to our note taking app. Open up `public/index.html` and edit the `title` tag to the following:

{% highlight html %}
<title>Scratch - A simple note taking app</title>
{% endhighlight %}

Create React App comes with pre-loaded with a pretty convinient yet minimal developement environment. It includes live reloading, a testing framework, ES6 support, and [much more](https://github.com/facebookincubator/create-react-app#why-use-this).

Next, we are going to create our app icon and update the favicons.
