---
layout: post
title: Set up Bootstrap
date: 2017-01-09 00:00:00
description: Bootstrap is a UI framework that makes it easy to build consistent responsive web apps. We are going to use Bootstrap with our React.js project using the React-Bootstrap library. React-Bootstrap allows you to use Bootstrap in the form of standard React components.
context: true
comments_id: set-up-bootstrap/118
---

A big part of writing web applications is having a UI Kit to help create the interface of the application. We are going to use [Bootstrap](http://getbootstrap.com) for our note taking app. While Bootstrap can be used directly with React; the preferred way is to use it with the [React-Bootstrap](https://react-bootstrap.github.io) package. This makes our markup a lot simpler to implement and understand.

### Installing React Bootstrap

<img class="code-marker" src="/assets/s.png" />Run the following command in your working directory.

``` bash
$ npm install react-bootstrap@0.32.4 --save
```

This installs the NPM package and adds the dependency to your `package.json`.

### Add Bootstrap Styles

<img class="code-marker" src="/assets/s.png" />React Bootstrap uses the standard Bootstrap v3 styles; so just add the following styles to your `public/index.html`.

``` html
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
```

We'll also tweak the styles of the form fields so that the mobile browser does not zoom in on them on focus. We just need them to have a minimum font size of `16px` to prevent the zoom.

<img class="code-marker" src="/assets/s.png" />To do that, let's add the following to our `src/index.css`.

``` css
select.form-control,
textarea.form-control,
input.form-control {
  font-size: 16px;
}
input[type=file] {
  width: 100%;
}
```

We are also setting the width of the input type file to prevent the page on mobile from overflowing and adding a scrollbar.

Now if you head over to your browser, you might notice that the styles have shifted a bit. This is because Bootstrap includes [Normalize.css](http://necolas.github.io/normalize.css/) to have a more consistent styles across browsers.

Next, we are going to create a few routes for our application and set up the React Router.
