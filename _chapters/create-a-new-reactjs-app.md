---
layout: post
title: Create a New React.js App
date: 2017-01-06 00:00:00
---

Let's get started with our frontend. We are going to create a single page app using [React.js](https://facebook.github.io/react/). We'll use the [Create React App](https://github.com/facebookincubator/create-react-app) project to set everything up. It is officially supported by the React team and conveniently packages all the dependencies for a React.js project.

### Install Create React App

{% include code-marker.html %} Run the following command in your working directory

{% highlight bash %}
$ npm install -g create-react-app
{% endhighlight %}

This installs the NPM package globally.

### Create a New App

{% include code-marker.html %} From your working directory, run the following command to create our note taking app.

{% highlight bash %}
$ create-react-app note-app
{% endhighlight %}

This should take a second to run, and it will create your new project.

{% include code-marker.html %} Now let's run our project.

{% highlight bash %}
$ cd note-app
$ npm start
{% endhighlight %}

This should fire up the newly created app in your browser.

![New Create React App screenshot]({{ site.url }}/assets/new-create-react-app.png)

### Change the Title

{% include code-marker.html %} Let's quickly change the title of our note taking app. Open up `public/index.html` and edit the `title` tag to the following:

{% highlight html %}
<title>Scratch - A simple note taking app</title>
{% endhighlight %}

Create React App comes pre-loaded with a pretty convenient yet minimal development environment. It includes live reloading, a testing framework, ES6 support, and [much more](https://github.com/facebookincubator/create-react-app#why-use-this).

Next, we are going to create our app icon and update the favicons.
