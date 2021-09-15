---
layout: post
title: Using Lerna and Yarn Workspaces with Serverless
description: In this chapter we look at how to manage large monorepo serverless projects with Lerna and Yarn Workspaces. We also share starter projects for Serverless Framework and SST to use as a template for future projects.
date: 2020-07-09 00:00:00
lang: en
ref: using-lerna-and-yarn-workspace-with-serverless
comments_id: using-lerna-and-yarn-workspaces-with-serverless/1958
---

In the [Organizing Serverless Projects]({% link _chapters/organizing-serverless-projects.md %}) chapter we covered the standard monorepo setup. This included [how to share code between your services]({% link _chapters/share-code-between-services.md %}) and [how to deploy a Serverless app with interdependent services]({% link _chapters/deploy-a-serverless-app-with-dependencies.md %}).

This setup works pretty well but as your team and project grows, you run into a new issue. You have some common code libraries that are used across multiple services. An update to these libraries would redeploy all your services. If your services were managed by separate folks on your team or by separate teams, this poses a problem. For any change made to the common code, would require all the other folks on your team to test or update their services.

Here it makes sense to manage your common code libraries as packages. So your services could potentially be using different version of the same package. This will allow your team to update to the newer version of the package when it works best for them. Avoiding the scenario where a small change to some common code breaks all the services that depend on it.

However, managing these packages in the same repo can be really challenging. To tackle this issue we are going to use:

- [Yarn Workspaces](https://classic.yarnpkg.com/en/docs/workspaces/)

  This optimizes our repo by hoisting all of our separate `node_modules/` to the root level. So that a single `yarn install` command installs the NPM modules for all our services and packages.

- [Lerna](https://lerna.js.org)

  This helps us manage our packages, publish them, and keeps track of the dependencies between them.

Lerna and Yarn Workspaces together helps create a monorepo setup that allows our serverless project to scale as it grows.

#### Starter Templates

To help get you started with this, we created two starter projects for 

- [**Serverless Framework Lerna + Yarn Workspaces Starter**](#serverless-framework-starter)
- [**SST Lerna + Yarn Workspaces Monorepo Starter**](#sst-starter)

These starter templates are:

- Designed to scale for larger projects
- Maintains internal dependencies as packages
- Uses Lerna to figure out which services have been updated 
- Supports publishing dependencies as private npm packages
- Uses Yarn Workspaces to hoist packages to the root `node_modules/` directory

This will help get you started with this setup. But if you are not familiar with Lerna or Yarn Workspaces, make sure to check out their docs.

Let's look at both of these starters.

-----

## Serverless Framework Starter

Check out the repo here — [**github.com/AnomalyInnovations/serverless-lerna-yarn-starter**](https://github.com/AnomalyInnovations/serverless-lerna-yarn-starter)

### Installation

To create a new Serverless project

``` bash
$ serverless install --url https://github.com/AnomalyInnovations/serverless-lerna-yarn-starter --name my-project
```

Enter the new directory

``` bash
$ cd my-project
```

Install NPM packages for the entire project

``` bash
$ yarn
```

### How It Works

The directory structure roughly looks like:

``` txt
package.json
/libs
/packages
  /sample-package
    index.js
    package.json
/services
  /service1
    handler.js
    package.json
    serverless.yml
  /service2
    handler.js
    package.json
    serverless.yml
```

This repo is split into 3 directories. Each with a different purpose:

- packages

  These are internal packages that are used in our services. Each contains a `package.json` and can be optionally published to NPM. Any changes to a package should only deploy the service that depends on it.

- services

  These are Serverless Framework services that are deployed. Has a `package.json` and `serverless.yml`. There are two sample services.

  1. `service1`: Depends on the `sample-package`. This means that if it changes, we want to deploy `service1`.
  2. `service2`: Does not depend on any internal packages.

  More on deployments below.

- libs

  Any common code that you might not want to maintain as a package. Does NOT have a `package.json`. Any changes here should redeploy all our services.

The `packages/` and `services/` directories are Yarn Workspaces.

#### Services

The Serverless Framework services are meant to be managed on their own. Each service is based on our [Serverless Node.js Starter](https://github.com/AnomalyInnovations/serverless-nodejs-starter). It uses the [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle) plugin (based on [Webpack](https://webpack.js.org)) to create optimized Lambda packages.

This is good for keeping your Lambda packages small. But it also ensures that you can have Yarn hoist all your NPM packages to the project root. Without Webpack, you'll need to disable hoisting since Serverless Framework does not package the dependencies of a service correctly on its own.

Install an NPM package inside a service.

``` bash
$ yarn add some-npm-package
```

Run a function locally.

``` bash
$ serverless invoke local -f get
```

Run tests in a service.

``` bash
$ yarn test
```

Deploy the service.

``` bash
$ serverless deploy
```

Deploy a single function.

``` bash
$ serverless deploy function -f get
```

To add a new service.

``` bash
$ cd services/
$ serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name new-service
$ cd new-service
$ yarn
```

#### Packages

Since each package has its own `package.json`, you can manage it just like you would any other NPM package.

To add a new package.

``` bash
$ mkdir packages/new-package
$ yarn init
```

Packages can also be optionally published to NPM.

#### Libs

If you need to add any other common code in your repo that won't be maintained as a package, add it to the `libs/` directory. It does not contain a `package.json`. This means that you'll need to install any NPM packages as dependencies in the root.

To install an NPM package at the root.

``` bash
$ yarn add -W some-npm-package
```

### Deployment

We want to ensure that only the services that have been updated get deployed. This means that, if a change is made to:

- services

  Only the service that has been changed should be deployed. For ex, if you change any code in `service1`, then `service2` should not be deployed.

- packages

  If a package is changed, then only the service that depends on this package should be deployed. For ex, if `sample-package` is changed, then `service1` should be deployed.

- libs

  If any of the libs are changed, then all services will get deployed.

#### Deployment Algorithm

To implement the above, use the following algorithm in your CI:

1. Run `lerna ls --since ${prevCommitSHA} -all` to list all packages that have changed since the last successful deployment. If this list includes one of the services, then deploy it.
2. Run `git diff --name-only ${prevCommitSHA} ${currentCommitSHA}` to get a list of all the updated files. If they don't belong to any of your Lerna packages (`lerna ls -all`), deploy all the services.
3. Otherwise skip the deployment.


### Deploying Through Seed

[Seed](https://seed.run) supports deploying Serverless Framework monorepo projects that use Lerna and Yarn Workspaces. To enable it, add the following to the `seed.yml` in your repo root:

``` yaml
check_code_change: lerna
```

To test this:

**Add the App**

1. Fork this repo and add it to [your Seed account](https://console.seed.run).
2. Add both of the services.
3. Deploy your app once.

**Update a Service**

- Make a change in `services/service2/handler.js` and git push.
- Notice that `service2` has been deployed while `service1` was skipped.

**Update a Package**

- Make a change in `packages/sample-package/index.js` and git push.
- Notice that `service1` should be deployed while `service2` will have been skipped.

**Update a Lib**

- Finally, make a change in `libs/index.js` and git push.
- Both `service1` and `service2` should've been deployed.

------

## SST Starter

Check out the repo here — [**github.com/AnomalyInnovations/serverless-stack/lerna-yarn-starter**](https://github.com/serverless-stack/lerna-yarn-starter)

### Installation

Start by cloning this repo

``` bash
$ git clone https://github.com/serverless-stack/lerna-yarn-starter my-project
```

Enter the new directory

``` bash
$ cd my-project
```

Install npm packages for the entire project

``` bash
$ yarn
```

### How It Works

The directory structure roughly looks like:

``` txt
package.json
/lib
/frontend
  package.json
/src
  /services
    /service1
      handler.js
      package.json
    /service2
      handler.js
      package.json
  /packages
    /sample-package
      index.js
      package.json
  /util
```

This repo is split into a few parts. Each with a different purpose:

- `lib/`

  This is where the CDK code for your app lives. It defines the infrastructure of your serverless app.

- `src/`

  This is where the code for your Lambda function are. It is further organized into services. Where each service is a collection of Lambda functions.

- `src/services/`

  These are services that are deployed as Lambda functions. Has a `package.json` and an entry point. There are two sample services.

  1. `service1`: Depends on the `sample-package`.
  2. `service2`: Does not depend on any internal packages.

- `src/packages/`

  These are internal packages that are used in our services. Each contains a `package.json` and can be optionally published to npm.

- `src/util/`

  Any common code that you might not want to maintain as a package. Does NOT have a `package.json`.

- `frontend/`

  A sample frontend React app that is a part of our serverless app.

The `src/packages/`, `src/services/`, and `frontend/` directories are Yarn Workspaces.

#### Services

Each service is a collection of Lambda functions with a similar purpose. They are meant to be managed on their own. They each have their own `package.json` and the versions of the dependencies should be kept separate from the other services. SST internally uses [esbuild](https://github.com/evanw/esbuild) to optimally package each Lambda function in a service.

This is good for keeping your Lambda packages small. But Yarn Workspaces also ensures that it hoists all your npm packages to the project root.

#### Packages

Since each package has its own `package.json`, you can manage it just like you would any other npm package.

To add a new package:

``` bash
$ mkdir src/packages/new-package
$ yarn init
```

Packages can also be optionally published to npm.

To use a package:

```bash
$ yarn add new-package@1.0.0
```

Note that packages should be added by specifying the version number declared in their `package.json`. Otherwise, Yarn tries to find the dependency in the registry.

#### Util

If you need to add any other common code in your repo that won't be maintained as a package, add it to the util directory. It does not contain a `package.json`. This means that you'll need to install any npm packages as dependencies in the root.

To install an npm package at the root.

``` bash
$ yarn add -W some-npm-package
```

While it's convenient to add all the common code to the util, it has a downside. If a team updates the util, all the services that are dependent on it will need to test this change before deploying. In contrast, a package can be locked to a specific version and can be upgraded when the team chooses to.

### Deployment

SST will handle all the dependencies internally and deploy all the services (and the frontend) in order.

### Deploying Through Seed

[Seed](https://seed.run) supports deploying SST monorepo projects that use Lerna and Yarn Workspaces out of the box.

------

These starters should give you a great template to build your next monorepo serverless project. So give it a try and let us know what you think!
