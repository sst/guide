<p align="center">
  <a href="https://serverless-stack.com/">
    <img alt="Serverless Stack" src="https://github.com/AnomalyInnovations/serverless-stack-com/raw/master/assets/logo-large.png" width="377" />
  </a>
</p>

<p align="center">
  <b>Learn to Build Full-Stack Apps with Serverless and React</b>
</p>

<p align="center">
  <a href="https://discourse.serverless-stack.com"><img alt="Discourse posts" src="https://img.shields.io/discourse/https/discourse.serverless-stack.com/posts.svg?style=for-the-badge" /></a>
  <a href="https://twitter.com/Anomaly_Inv"><img alt="Twitter follow" src="https://img.shields.io/twitter/follow/anomaly_inv.svg?label=twitter&style=for-the-badge" /></a>
  <a href="https://gitter.im/serverless-stack/Lobby"><img alt="Chat on Gitter" src="https://img.shields.io/gitter/room/serverless-stack/serverless-stack.svg?style=for-the-badge" /></a>
</p>

------------------------------------------------------------------------------------

[Serverless Stack](https://serverless-stack.com) is an open source guide for building and deploying full-stack apps using Serverless and React on AWS.

We are going to create a [note taking app](https://demo2.serverless-stack.com) from scratch using React.js, AWS Lambda, API Gateway, DynamoDB, and Cognito.

![Demo App](assets/completed-app-desktop.png)

It is a single-page React app powered by a serverless CRUD API. We also cover how add user authentication and handle file uploads.

The entire guide is hosted on GitHub and we use [Discourse][Discourse] for our comments. With the help of the community we add more detail to the guide and keep it up to date.

## Project Goals

- Provide a free comprehensive resource
- Add more content to build on core concepts
- Keep the content accurate and up to date
- Help people resolve their issues

## Getting Help

- If you are running into issues with a specific chapter, post in the comments for that [chapter][Discourse].
- Open a [new issue](../../issues/new) if you've found a bug
- Or if you have a suggestion create a [new topic][Discourse] in our forums
- If you've found a typo, edit the chapter and submit a [pull request][PR].

## Source for the Demo App

- [Backend Serverless API](https://github.com/AnomalyInnovations/serverless-stack-demo-api)
- [Frontend React app](https://github.com/AnomalyInnovations/serverless-stack-demo-client)

## Contributing

Thank you for your considering to contribute. [Read more about how you can contribute to Serverless Stack][Contributing].

## Running Locally

Serverless Stack is built using [Jekyll](https://jekyllrb.com). [Follow these steps to install Jekyll](https://jekyllrb.com/docs/installation/).

#### Viewing Locally

To install, run the following in the root of the project.

``` bash
$ bundle install
```

And to view locally.

``` bash
$ bundle exec jekyll serve
```

You can now view the guide locally by visiting `http://localhost:4000/`.

You can also turn on live reloading and incremental builds while editing.

``` bash
$ bundle exec jekyll serve --incremental --livereload
```

#### Generating the PDF

You can generate the PDF locally on macOS by following these steps.

1. Generate a `Cover.pdf` with latest version and date
   1. Create an `ebook` folder in `~/Downloads` (for example).
   2. Update the date and version in the `etc/cover.html`
   3. Open the cover page locally in Safari by going to `file:///Users/frank/Sites/ServerlessStackCom/etc/cover.html`.
   4. Hit the **Export to PDF…** button.
   5. Place `Cover.pdf` in the `~/Downloads/ebook` folder.
2. Ensure `ebook` folder is an option when hitting the **Export to PDF…** button in Safari.
3. In the terminal, run `osascript pdf.scpt` in the `etc/` directory of this repository.

We are looking for a better way to generate the PDF (and other eBook) formats. If you've got any ideas [consider contributing][Contributing].

## Sponsors

[**Sponsor Serverless Stack on Patreon**](https://www.patreon.com/serverless_stack) if you've found this guide useful or would like to be an official supporter. [A big thanks to our supporters](https://serverless-stack.com/sponsors.html#backers)!

## Maintainers

Serverless Stack is maintained by [Anomaly Innovations](https://anoma.ly/). [**Subscribe to our newsletter**](https://emailoctopus.com/lists/1c11b9a8-1500-11e8-a3c9-06b79b628af2/forms/subscribe) for updates on Serverless Stack.

## Contributors

Thanks to these folks for their contributions to the content of Serverless Stack.

- [Peter Eman Paver Abastillas](https://github.com/jatazoulja): Social login chapters
- [Bernardo Bugmann](https://github.com/bernardobugmann): Translating chapters to Portuguese
- [Sebastian Gutierrez](https://github.com/pepas24): Translating chapters to Spanish and adding copy button for code snippets
- [Vincent Oliveira](https://github.com/vincentoliveira): Translating chapters to French
- [Leonardo Gonzalez](https://github.com/leogonzalez): Translating chapters to Portuguese
- [Vieko Franetovic](https://github.com/vieko): Translating chapters to Spanish
- [Christian Kaindl](https://github.com/christiankaindl): Translating chapters to German


[Discourse]: https://discourse.serverless-stack.com
[Contributing]: CONTRIBUTING.md
[PR]: ../../compare
