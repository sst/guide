<p align="center">
  <a href="https://sst.dev/">
    <img alt="SST" src="https://raw.githubusercontent.com/sst/identity/main/variants/sst-full.svg" width="300" />
  </a>
</p>


<p align="center">
  <a href="https://sst.dev/discord"><img alt="Discord" src="https://img.shields.io/discord/983865673656705025?style=flat-square&label=Discord" /></a>
  <a href="https://twitter.com/sst_dev"><img alt="Twitter" src="https://img.shields.io/badge/Twitter-26a7de?style=flat-square" /></a>
  <a href="https://www.youtube.com/c/sst-dev"><img alt="YouTube" src="https://img.shields.io/youtube/channel/subscribers/UCho8kA4-HMolEq6qEMRJetg?style=flat-square&label=YouTube" /></a>
</p>

---

Repo for [**SST.dev**](https://sst.dev) and the [SST Guide](https://sst.dev/guide.html). If you are looking for the SST repo, [head over here](https://github.com/sst/sst).

## SST Guide

The guide is a comprehensive open source tutorial for building and deploying full-stack apps using Serverless and React on AWS.

We are going to create a [note taking app](https://demo.sst.dev) from scratch using React.js, AWS Lambda, API Gateway, DynamoDB, and Cognito.

![Demo App](assets/completed-app-desktop.png)

It is a single-page React app powered by a serverless CRUD API. We also cover how add user authentication and handle file uploads.

### Project Goals

- Provide a free comprehensive resource
- Add more content to build on core concepts
- Keep the content accurate and up to date
- Help people resolve their issues

### Getting Help

- If you are running into issues with a specific chapter, join us on [Discord][discord] and post in `#help`.
- Open a [new issue](../../issues/new) if you've found a bug
- If you've found a typo, edit the chapter and submit a [pull request][pr].

#### Source for the Demo App

- [Demo Notes App](https://github.com/sst/demo-notes-app)

## Contributing

Thank you for your considering to contribute. [Read more about how you can contribute to SST][contributing].

### Running Locally

SST is built using [Jekyll](https://jekyllrb.com). [Follow these steps to install Jekyll](https://jekyllrb.com/docs/installation/).

### Viewing Locally

To install, run the following in the root of the project.

```bash
$ bundle install
```

And to view locally.

```bash
$ bundle exec jekyll serve
```

You can now view the guide locally by visiting `http://localhost:4000/`.

You can also turn on live reloading and incremental builds while editing.

```bash
$ bundle exec jekyll serve --incremental --livereload
```

#### Generating the eBook

We use [Pandoc](https://pandoc.org) to create the eBook. You can generate it locally by following these steps.

```bash
$ cd ~/Sites/sst.dev/etc/ebook
$ make start
```

This'll start a Docker instance. Inside the Docker run:

```bash
$ make pdf
$ make epub
```

The above are run automatically through [Github Actions](https://github.com/sst/sst.dev/actions) in this repo:

- When a new commit is pushed to master
- And when a new tag is pushed, the generated eBook is uploaded to S3

## Contributors

Thanks to these folks for their contributions to the content of SST.

- [Peter Eman Paver Abastillas](https://github.com/jatazoulja): Social login chapters
- [Bernardo Bugmann](https://github.com/bernardobugmann): Translating chapters to Portuguese
- [Sebastian Gutierrez](https://github.com/pepas24): Translating chapters to Spanish and adding copy button for code snippets
- [Vincent Oliveira](https://github.com/vincentoliveira): Translating chapters to French
- [Leonardo Gonzalez](https://github.com/leogonzalez): Translating chapters to Portuguese
- [Vieko Franetovic](https://github.com/vieko): Translating chapters to Spanish
- [Christian Kaindl](https://github.com/christiankaindl): Translating chapters to German
- [Jae Chul Kim](https://github.com/bsg-bob): Translating chapters to Korean
- [Ben Force](https://twitter.com/theBenForce): Extra credit chapters
- [Eze Sunday](https://twitter.com/ezesundayeze): Extra credit chapters
- [Maniteja Pratha](https://twitter.com/PrataManitej): Vue.js example

---

**Join our community** [Discord][discord] | [YouTube](https://www.youtube.com/c/sst-dev) | [Twitter](https://twitter.com/SST_dev) | [Contribute][contributing]

[discourse]: https://discourse.sst.dev
[discord]: https://sst.dev/discord
[contributing]: CONTRIBUTING.md
[pr]: ../../compare
