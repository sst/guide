---
layout: post
title: Add App Favicons
---

Create React App generates a simple favicon for our app and places it in `public/favicon.ico`. However, getting the favicon to work on all browsers and mobile platforms requires a little bit more work. There are quite a few different requirements and dimensions. And this gives us a good oppurtunity to learn how to include files in the `public` directory of our app.

For our example we are going to start with a simple image and generate the various version from it.

<img alt="App Icon" width="130" height="130" src="{{ site.url }}/assets/icon.png" />

To ensure that our icon works for most of our targetted platforms we'll use a service called the [Favicon Generator](http://realfavicongenerator.net).

![Realfavicongenerator.net screenshot]({{ site.url }}/assets/realfavicongenerator.png)

Once you upload your icon, it'll generate a few different versions that you need.

![Realfavicongenerator.net completed screenshot]({{ site.url }}/assets/realfavicongenerator-completed.png)

Download the generated package and copy all the files over to your `public` directory. To include a file from the `public` directory in your HTML, Create React App needs the `%PUBLIC_URL%` prefix.

Copy the generated code and add the `%PUBLIC_URL%` prefix to all the URLs. It should look something like this.

{% highlight html %}
<link rel="apple-touch-icon" sizes="180x180" href="%PUBLIC_URL%/apple-touch-icon.png">
<link rel="icon" type="image/png" href="%PUBLIC_URL%/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="%PUBLIC_URL%/favicon-16x16.png" sizes="16x16">
<link rel="manifest" href="%PUBLIC_URL%/manifest.json">
<link rel="mask-icon" href="%PUBLIC_URL%/safari-pinned-tab.svg" color="#5bbad5">
<meta name="theme-color" content="#ffffff">
{% endhighlight %}

Add it to your `public/index.html` and remove the following line that references the original favicon.

{% highlight html %}
<link rel="shortcut icon" href="%PUBLIC_URL%/favicon.ico">
{% endhighlight %}

Finally head over to your browser and try the `/favicon-32x32.png` path to ensure that the files were added correctly.

Next we are going to look into setting up custom fonts in our app.
