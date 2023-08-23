---
layout: post
title: Add App Favicons
date: 2017-01-07 00:00:00
lang: en
ref: add-app-favicons
description: To generate app icons and favicons for our React.js app we will use the Realfavicongenerator.net service. This will replace the default favicon that the Vite React template comes with.
comments_id: add-app-favicons/155
---

Vite generates a simple favicon for our app and places it in `public/vite.svg` of our app. However, getting the favicon to work on all browsers and mobile platforms requires a little more work. There are quite a few different requirements and dimensions. And this gives us a good opportunity to learn how to include files in the `public/` directory of our app.

For our example, we are going to start with a simple image and generate the various versions from it.

**Right-click to download** the following image. Or head over to this link to download it — [{{ '/assets/scratch-icon.png' | absolute_url }}]({{ '/assets/scratch-icon.png' | absolute_url }}){:target="_blank"}

<img alt="App Icon" width="130" height="130" src="/assets/scratch-icon.png" />

To ensure that our icon works for most of our targeted platforms we'll use a service called the [**Favicon Generator**](http://realfavicongenerator.net){:target="_blank"}.

Click **Select your Favicon picture** to upload our icon.

![Realfavicongenerator.net screenshot](/assets/realfavicongenerator.png)

Once you upload your icon, it'll show you a preview of your icon on various platforms. Scroll down the page and hit the **Generate your Favicons and HTML code** button.

![Realfavicongenerator.net screenshot](/assets/realfavicongenerator-generate.png)

This should generate your favicon package and the accompanying code.

{%change%} Click **Favicon package** to download the generated favicons. And copy all the files over to your `public/` directory.

![Realfavicongenerator.net completed screenshot](/assets/realfavicongenerator-completed.png)

Let's remove the old icons files.

{%note%} 
We'll be working exclusively **in the `packages/frontend/` directory** for the rest of the frontend part of the guide.
{%endnote%}

{%change%} Then replace the contents of `public/site.webmanifest` with the following:

```json
{
  "short_name": "Scratch",
  "name": "Scratch Note Taking App",
  "icons": [
    {
      "src": "android-chrome-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "android-chrome-256x256.png",
      "sizes": "256x256",
      "type": "image/png"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#ffffff",
  "background_color": "#ffffff"
}
```

{%change%} Add this to the `<head>` in your `public/index.html`.

```html
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="msapplication-TileColor" content="#da532c">
<meta name="theme-color" content="#ffffff">
<meta name="description" content="A simple note taking app" />
```

{%change%} And **remove** the following lines that reference the original favicon.

```html
<link rel="icon" type="image/svg+xml" href="/vite.svg" />
```

Finally head over to your browser and add `/favicon-32x32.png` to the base URL path to ensure that the files were added correctly.

Next we are going to look into setting up custom fonts in our app.
