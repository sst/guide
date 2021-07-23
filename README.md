<p align="center">
  <a href="https://serverless-stack.com/">
    <img alt="Serverless Stack" src="https://github.com/AnomalyInnovations/serverless-stack-com/raw/master/assets/logo-large.png" width="377" />
  </a>
</p>

<p align="center">
  <a href="https://discourse.serverless-stack.com"><img alt="Discourse posts" src="https://img.shields.io/discourse/https/discourse.serverless-stack.com/posts.svg?style=for-the-badge" /></a>
  <a href="https://twitter.com/ServerlessStack"><img alt="Twitter follow" src="https://img.shields.io/twitter/follow/serverlessstack.svg?label=twitter&style=for-the-badge" /></a>
  <a href="https://launchpass.com/serverless-stack"><img alt="Chat on Slack" src="https://img.shields.io/badge/CHAT-ON%20SLACK-brightgreen?style=for-the-badge" /></a>
</p>

------------------------------------------------------------------------------------

The [Serverless Stack Guide](https://serverless-stack.com/#guide) is a comprehensive open source tutorial for building and deploying full-stack apps using Serverless and React on AWS.

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

#### Generating the eBook

We use [Pandoc](https://pandoc.org) to create the eBook. You can generate it locally by following these steps.

``` bash
$ cd ~/Sites/ServerlessStackCom/etc/ebook
$ make start
```

This'll start a Docker instance. Inside the Docker run:

``` bash
$ make pdf
$ make epub
```

The above are run automatically through [Github Actions](https://github.com/AnomalyInnovations/serverless-stack-com/actions) in this repo:

- When a new commit is pushed to master
- And when a new tag is pushed, the generated eBook is uploaded to S3

<!--
## Sponsors

[**Sponsor Serverless Stack on GitHub**](https://github.com/sponsors/jayair) if you've found this guide useful or would like to be an official supporter. [A big thanks to our supporters](https://serverless-stack.com/sponsors.html)!
-->

## Contributors

Thanks to these folks for their contributions to the content of Serverless Stack.

- [Peter Eman Paver Abastillas](https://github.com/jatazoulja): Social login chapters
- [Bernardo Bugmann](https://github.com/bernardobugmann): Translating chapters to Portuguese
- [Sebastian Gutierrez](https://github.com/pepas24): Translating chapters to Spanish and adding copy button for code snippets
- [Vincent Oliveira](https://github.com/vincentoliveira): Translating chapters to French
- [Leonardo Gonzalez](https://github.com/leogonzalez): Translating chapters to Portuguese
- [Vieko Franetovic](https://github.com/vieko): Translating chapters to Spanish
- [Christian Kaindl](https://github.com/christiankaindl): Translating chapters to German
- [Jae Chul Kim](https://github.com/bsg-bob): Translating chapters to Korean

---

This repo is maintained by [Serverless Stack](https://serverless-stack.com).


[Slack]: https://launchpass.com/serverless-stack
[Discourse]: https://discourse.serverless-stack.com
[Contributing]: CONTRIBUTING.md
[PR]: ../../compare
