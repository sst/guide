---
layout: post
title: Set up Bootstrap
date: 2017-01-09 00:00:00
lang: en
ref: set-up-bootstrap
description: Bootstrap is a UI framework that makes it easy to build consistent responsive web apps. We are going to use Bootstrap with our React.js project using the React Bootstrap and the Bootstrap icons from the React Icons package. React Bootstrap and React Icons allow you to use them as standard React components.
comments_id: set-up-bootstrap/118
---

A big part of writing web applications is having a UI Kit to help create the interface of the application. We are going to use [Bootstrap](http://getbootstrap.com) for our note taking app. While Bootstrap can be used directly with React; the preferred way is to use it with the [React Bootstrap](https://react-bootstrap.github.io) package. This makes our markup a lot simpler to implement and understand.

We also need a couple of icons in our application. We'll be using the [React Icons](https://react-icons.github.io/react-icons/) package for this. It allows us to include icons in our React app as standard React components.

### Installing React Bootstrap

{%change%} Run the following command in your `frontend/` directory and **not** in your project root

```bash
$ npm install bootstrap react-bootstrap react-icons
```

This installs the npm packages and adds the dependencies to your `package.json` of your React app.

### Add Bootstrap Styles

{%change%} React Bootstrap uses the standard Bootstrap v5 styles; so just add the following styles to your `src/index.js`.

```js
import "bootstrap/dist/css/bootstrap.min.css";
```

We'll also tweak the styles of the form fields so that the mobile browser does not zoom in on them on focus. We just need them to have a minimum font size of `16px` to prevent the zoom.

{%change%} To do that, let's add the following to our `src/index.css`.

```css
select.form-control,
textarea.form-control,
input.form-control {
  font-size: 1rem;
}
input[type="file"] {
  width: 100%;
}
```

We are also setting the width of the input type file to prevent the page on mobile from overflowing and adding a scrollbar.

Now if you head over to your browser, you might notice that the styles have shifted a bit. This is because Bootstrap includes [Normalize.css](http://necolas.github.io/normalize.css/) to have a more consistent styles across browsers.

Next, we are going to create a few routes for our application and set up the React Router.
