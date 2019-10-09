---
layout: post
title: Create a New React.js App
date: 2017-01-06 00:00:00
lang: en
ref: create-a-new-react-js-app
description: Create React App helps you build React.js app with no configuration. Install the Create React App CLI using the NPM package and use the command to start a new React.js project.
context: true
comments_id: create-a-new-react-js-app/68
---

Let's get started with our frontend. We are going to create a single page app using [React.js](https://facebook.github.io/react/). We'll use the [Create React App](https://github.com/facebookincubator/create-react-app) project to set everything up. It is officially supported by the React team and conveniently packages all the dependencies for a React.js project.

<img class="code-marker" src="/assets/s.png" />Move out of the directory that we were working in for the backend.

``` bash
$ cd ../
```

### Create a New React App

<img class="code-marker" src="/assets/s.png" />Run the following command to create the client for our notes app.

``` bash
$ npx create-react-app notes-app-client --use-npm
```

This should take a second to run, and it will create your new project and your new working directory.

<img class="code-marker" src="/assets/s.png" />Now let's go into our working directory and run our project.

``` bash
$ cd notes-app-client
$ npm start
```

This should fire up the newly created app in your browser.

![New Create React App screenshot](/assets/new-create-react-app.png)

### Change the Title

<img class="code-marker" src="/assets/s.png" />Let's quickly change the title of our note taking app. Open up `public/index.html` and edit the `title` tag to the following:

``` html
<title>Scratch - A simple note taking app</title>
```

Create React App comes pre-loaded with a pretty convenient yet minimal development environment. It includes live reloading, a testing framework, ES6 support, and [much more](https://github.com/facebookincubator/create-react-app#why-use-this).

Now we are ready to build our frontend. But just like we did with the backend, let's first create a GitHub repo to store our code.
