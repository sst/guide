---
layout: post
title: Create an SST app
date: 2021-08-17 00:00:00
lang: en
description: Create your first SST app by cloning the template from GitHub.
redirect_from:
  - /chapters/building-a-cdk-app-with-sst.html
  - /chapters/initialize-a-github-repo.html
  - /chapters/initialize-the-backend-repo.html
  - /chapters/initialize-the-frontend-repo.html
ref: create-an-sst-app
comments_id: create-an-sst-app/2462
---

Now that we have some background on SST and _infrastructure as code_, we are ready to create our first SST app!

We are going to use a [template SST project][Template], it comes with a good monorepo setup. It'll help us organize our frontend and APIs.

Head over to — [**github.com/sst/monorepo-template**][Template], click **Use this template** > **Create a new repository**. 

![Use the SST monorepo GitHub template screenshot](/assets/part2/use-the-sst-monorepo-github-template-screenshot.png)

Give your repository a name, in our case we are calling it `notes`. Next hit **Create repository**.

![Name new GitHub repository screenshot](/assets/part2/name-new-github-repository.png)

Once your repository is created, copy the repository URL.

{%change%} Run the following in your working directory.

```bash
$ git clone <REPO_URL>
$ cd notes
```

{%change%} Use your app name in the template.

```bash
$ npx replace-in-file /monorepo-template/g notes **/*.* --verbose
```

{%change%} Install the dependencies.

```bash
$ npm install
```

By default, the template is creating an API. You can see this in the `sst.config.ts` in the root.

```ts
/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
  app(input) {
    return {
      name: "notes",
      removal: input?.stage === "production" ? "retain" : "remove",
      home: "aws",
    };
  },
  async run() {
    await import("./infra/storage");
    const api = await import("./infra/api");

    return {
      api: api.myApi.url,
    };
  },
});
```

{%caution%}
To rename an app, you’ll need to remove the resources from the old one and deploy to the new one.
{%endcaution%}

The name of your app as you might recall is `notes`. A word of caution on IaC, if you rename your app after you deploy it, it doesn't rename the previously created resources in your app. You'll need to remove your old app and redeploy it again with the new name. To get a better sense of this, you can read more about the [SST workflow]({{ site.ion_url }}/docs/workflow){:target="_blank"}.

## Project layout

An SST app is made up of two parts.

1. `infra/` — App Infrastructure

   The code that describes the infrastructure of your serverless app is placed in the `infra/` directory of your project.

2. `packages/` — App Code

   The Lambda function code that's run when your API is invoked is placed in the `packages/functions` directory of your project, the `packages/core` contains our business logic, and the `packages/scripts` are for any one-off scripts we might create.

Later on we'll be adding a `packages/frontend/` directory for our React app.

The starter project that's created is defining a simple _Hello World_ API. In the next chapter, we'll be deploying it and running it locally.

[Template]: (https://github.com/sst/monorepo-template)
