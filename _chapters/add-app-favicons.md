---
layout: post
title: Add App Favicons
date: 2017-01-07 00:00:00
lang: en
ref: add-app-favicons
description: To generate app icons and favicons for our React.js app we will use the Realfavicongenerator.net service. This will replace the default favicon that Create React App comes with.
comments_id: add-app-favicons/155
---

Create React App generates a simple favicon for our app and places it in `public/favicon.ico` of our app. However, getting the favicon to work on all browsers and mobile platforms requires a little more work. There are quite a few different requirements and dimensions. And this gives us a good opportunity to learn how to include files in the `public/` directory of our app.

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
We'll be working exclusively in the `frontend/` directory through the chapter on securing React pages.**
{%endnote%}

{%change%} Run the following from our `frontend/` directory.

```bash
$ rm public/logo192.png public/logo512.png public/favicon.ico
```

{%change%} Then replace the contents of `public/manifest.json` with the following:

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

To include a file from the `public/` directory in your HTML, Create React App needs the `%PUBLIC_URL%` prefix.

{%change%} Add this to the `<head>` in your `public/index.html`.

```html
<link
  rel="apple-touch-icon"
  sizes="180x180"
  href="%PUBLIC_URL%/apple-touch-icon.png"
/>
<link
  rel="icon"
  type="image/png"
  href="%PUBLIC_URL%/favicon-32x32.png"
  sizes="32x32"
/>
<link
  rel="icon"
  type="image/png"
  href="%PUBLIC_URL%/favicon-16x16.png"
  sizes="16x16"
/>
<link
  rel="mask-icon"
  href="%PUBLIC_URL%/safari-pinned-tab.svg"
  color="#5bbad5"
/>
<meta name="description" content="A simple note taking app" />
<meta name="theme-color" content="#ffffff" />
```

{%change%} And **remove** the following lines that reference the original favicon and theme color.

```html
    <link href="%PUBLIC_URL%/favicon.ico" rel="icon" />
<meta content="width=device-width, initial-scale=1" name="viewport" />
<meta content="#000000" name="theme-color" />
<meta
        content="Web site created using create-react-app"
        name="description"
/>
<link href="%PUBLIC_URL%/logo192.png" rel="apple-touch-icon" />

```

Finally head over to your browser and add `/favicon-32x32.png` to the base URL path to ensure that the files were added correctly.

Next we are going to look into setting up custom fonts in our app.
