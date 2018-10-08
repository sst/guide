# Contributing

Thank you for considering to contribute. Here is what Serverless Stack is trying to accomplish and how you can help. We use our [Gitter chat room][Gitter] for our contributors, feel free to join us there.

## Project Goals

We are trying to create a really comprehensive and up to date guide to help people build production ready full-stack serverless applications. To start, we are focussing on building a CRUD API backend with Serverless Framework on AWS and a single-page app web frontend using React.

We want Serverless Stack to cover a very broad collection of technologies, services, and concepts that gives people the confidence to use this guide to build their next project. Too often we come across tutorials or blog posts that sound very promising but leave us hanging once we get to the complicated bits.

However while we want to be as comprehensive as possible, we also want to make sure that you can get started easily. To achieve this we are using the following structure and layout.

## Project Structure

The guide is split up in the following way:

The Core:
- Part I: The basic aspects of creating a full-stack serverless app
- Part II: Some advanced concepts when you are getting your app ready for production

The Extensions
- Extra Credits: Standalone chapters/articles intended to supplement the first two parts and to extend some functionality of the demo app

Additionally, the demo app that people build as a part of the tutorial is split into the backend (a Serverless Framework project) and the frontend (a React app). Both these are in their separate Git repos.

Key chapters in the Core part of the guide are accompanied with branches in their respective demo app repos. This is used to track progress and as a reference as you work through the tutorial.


## How to Help

There are quite a few ways to help.

- Fix typos, grammatical errors, broken links, etc. in the current guide
- Help answer questions that people have in the forums
- [Keep the core guide updated](#keep-the-core-guide-updated)
- [Add an extra credit chapter](#add-an-extra-credit-chapter)
- [Improve tooling](#improve-tooling)
- [Translating to other languages](#translating-to-other-languages)

Additionally, you are welcome to provide general feedback and suggestions via our forums.


### Keep the core guide updated

Serverless Stack is reliant on a large number of services and open source libraries and projects. Here is what needs updating:

### Updating Screenshots

We want to keep the screenshots as consistent as possible to reduce any source of confusion. Here are some guidelines on taking a new screenshot.

- Use Safari with a window size of 1280x778 (or similar ratio).
- Mock any account details or private info on the screen using Safari's dev tools.
- Don't have any tabs or extra toolbars. Try to use the default Safari chrome. [Here is an example](https://raw.githubusercontent.com/AnomalyInnovations/serverless-stack-com/master/assets/contributing/safari-chrome.png).
- Take a screenshot of the browser window with the CMD+SHIFT+4 SPACE command.
- Use the Preview app to add pointers for input fields or buttons that need to be highlighted. [Here are the specific settings used](https://raw.githubusercontent.com/AnomalyInnovations/serverless-stack-com/master/assets/contributing/preview-arrow.png).

### Updating dependencies

To update the dependencies for one of the demo apps (backend or frontend):

- Find the chapter (with a demo repo sample and branch) where the dependency is first introduced
- Update the dependency in that branch and test it
- Update the dependency in all the branches that follow including master
- Submit PRs for all the branches that have been updated

For the steps in the tutorial:

- Make any necessary changes and submit a PR

Once all the PRs are merged, we'll tag the repo (tutorial & demo app) with the new version number and update the Changelog chapter.


### Add an Extra Credit Chapter

The core chapters are missing some extra details (for the sake of simplicity) that are necessary once you start customizing the Serverless Stack setup. Additionally, there are cases that we just don't handle in the core chapters. [Here is a rough list of topics that have been requested](https://github.com/AnomalyInnovations/serverless-stack-com/projects/1#column-2785572). This is not an exhaustive list. If you have some ideas to extend some of the demo app functionality, feel free to get in touch with us. Here is how to go about adding a new extra credit chapter:

- Let us know via [Gitter][Gitter] that you are planning to work on it
- Create a new issue in GitHub to track progress
- Fork the tutorial repo
- Copy the `_drafts/template.md` as a starting point for the chapter
- Move the new chapter(s) to `_chapters/new-chapter-name.md`
- Make sure to use a descriptive name for the chapter title and URL
- Add the title and URL to `_data/chapterlist.yml` under the Extra Credit section
- For any screenshots, create a new directory under `assets/new-chapter-name/` and add them there
- The Next and Previous buttons for navigating chapters are based on the `date:` field in the chapter's [front matter](https://jekyllrb.com/docs/frontmatter/). The date needs to be larger than the chapter it comes after and lesser than the one it comes before.
- Update the front matter's bio field information about you (the author)

For any changes to the demo app:

- Fork the repo for the demo app and make the changes
- Update the README to reflect that this is an extension to the tutorial demo app
- Reference the new forked repo in the chapter

Finally, submit a PR to the tutorial repo with the new changes. We'll review it, maybe suggest some edits or give you some feedback. Once everything looks okay we'll merge with master and publish it. We'll also create comments threads for your chapter in the forums and link to it.


### Improve Tooling

Currently we do a lot of manual work to publish updates and maintain the tutorial. You can help by contributing to improve the process. Feel free to get in touch if you're interested in helping out. Here is roughly what we need help with:

- Generating the Ebook

  The PDF version of Serverless Stack is very popular. Unfortunately it is generated manually using a set of AppleScripts stored in the `etc/` directory. It opens up Safari and prints to PDF. It would be much better if we could use a headless Chrome script to generate this. In addition to the PDF we need to figure out how to generate the EPUB format.

- Creating a pipeline

  We would like to create a Circle CI setup that automatically generates the PDF and uploads the latest version to S3 (where it is hosted) every time a new release is created to the tutorial. We would also like to run a simple suite of tests to ensure that the changes to the demo app repos are correct.

- Compress screenshots

  The images for the screenshots are quite large. It would be ideal if they can be compressed as a part of the build process.

### Translating to Other Languages

We currently have translation efforts for Spanish and Portuguese underway. If you'd like to get involved [refer to this thread](https://github.com/AnomalyInnovations/serverless-stack-com/issues/271).

To translate a chapter follow these steps:

1. Add the following to the frontmatter of the chapter you intend to translate.

   ``` yml
   ref: uri-of-the-chapter
   lang: en
   ```
   
   Here `uri-of-the-chapter` is the part of the url that represents the name of the chapter. For example, the [What is Serverless](https://serverless-stack.com/chapters/what-is-serverless.html) has a URI `what-is-serverless`.

2. Copy the file to `_chapters/[language-code]/[filename].md`

   Here the `language-code` is either `pt` or `es`. And the `filename` is up to you. It does not need to be the same as the English one.

3. Change the frontmatter to.

   ``` yml
   lang: language-code
   ```
   
   Again the `language-code` is either `pt` or `es`.
   

Note that the only thing linking the translation with the original is the `ref:` attribute in the frontmatter. Make sure that it is the same for both the files.

As an example, compare the [What is Serverless](https://serverless-stack.com/chapters/what-is-serverless.html) chapter:

- English version: https://github.com/AnomalyInnovations/serverless-stack-com/blob/master/_chapters/what-is-serverless.md
- Spanish version: https://github.com/AnomalyInnovations/serverless-stack-com/blob/master/_chapters/es/what-is-serverless.md

Feel free to [contact us](mailto:contact@anoma.ly) if you have any questions.
   

[Gitter]: https://gitter.im/serverless-stack/Lobby
