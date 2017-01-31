---
layout: post
title: Setting Up Bootstrap
---

A big part of writing web applications is having a UI Kit to help create the interface of the application. We are going to use [Bootstrap](http://getbootstrap.com) for our note taking app. While Boostrap can be used directly with React; the preferred way is to use it with the [React-Bootstrap](https://react-bootstrap.github.io) package. This makes our markup a lot simpler to implement and understand.

### Installing React Bootstrap

Run the following command in your working directory

{% highlight bash %}
npm install react-bootstrap --save
{% endhighlight %}

This installs the NPM package and adds the dependency to your `package.json`.

### Add Boostrap styles

React Bootstrap uses the standard Bootstrap styles; so just add the following styles to your `index.html`.

{% highlight html %}
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/latest/css/bootstrap.min.css">
{% endhighlight %}

Optionally, you can include a Bootstrap theme by just including it's styles.

{% highlight html %}
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/latest/css/bootstrap-theme.min.css">
{% endhighlight %}

Now if you head over to your browser, you might notice that the styles have shifted a bit. This is because Bootstrap includes [Normalize.css](http://necolas.github.io/normalize.css/) to have more consistent styles across browsers.

Next, we are going to create a few routes for our application and set up the React Router.
