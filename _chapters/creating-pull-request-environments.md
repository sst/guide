---
layout: post
title: Creating Pull Request Environments
description: In this chapter we'll look at the workflow for creating new pull request based environments for your Serverless app using Seed.
date: 2019-10-02 00:00:00
comments_id: creating-pull-request-environments/1318
---

Now that we are done working on our new feature, we would like our team lead to review our work before promoting it to production. To do that we are going to create a pull request and Seed will automatically create an ephemeral environment for it.

### Enable pull request workflow on Seed

To enable auto-deploying pull requests, head over to your app on Seed. Click **Settings**.

![Select app settings in Seed](/assets/best-practices/creating-pull-request-environments/select-app-settings-in-seed.png)

Scroll down to **Git Integration**. Then click **Enable Auto-Deploy PRs**.

![Select Enable Auto-Deploy PRs](/assets/best-practices/creating-pull-request-environments/select-enable-auto-deploy-prs.png)

Hit **Enable**.

![Select Enable Auto-Deploy](/assets/best-practices/creating-pull-request-environments/select-enable-auto-deploy.png)

### Create a pull request

Go to GitHub, and select the **like** branch. Then hit **New pull request**.

![Select New pull requests in GitHub](/assets/best-practices/creating-pull-request-environments/select-new-pull-requests-in-github.png)

Click **Create pull request**.

![Select Create pull request in GitHub](/assets/best-practices/creating-pull-request-environments/select-create-pull-request-in-github.png)

Now back in Seed, a new stage (in this case **pr2**) should be created and is being deployed automatically.

![Shoow pull request stage created](/assets/best-practices/creating-pull-request-environments/shoow-pull-request-stage-created.png)

After the **pr2** stage successfully deploys, you can see the deployed API endpoint on the PR page. You can give the endpoint to your frontend team for testing.

![Show API endpoint in GitHub PR page](/assets/best-practices/creating-pull-request-environments/show-api-endpoint-in-github-pr-page.png)

You can also access the **pr2** stage and the upstream **like** stage on Seed via the **View deployment** button. And you can see the deployment status for each service under the **checks** section.

![Show pull request checks in GitHub](/assets/best-practices/creating-pull-request-environments/show-pull-request-checks-in-github.png)

Now that our new feature has been reviewed, we are ready to merge it to master.

### Merge to master

Once your final test looks good, you are ready to merge the pull request. Go to GitHub's pr page and click **Merge pull request**.

![Select Merge pull request](/assets/best-practices/creating-pull-request-environments/select-merge-pull-request.png)

Back in Seed, this will trigger a deployment in the **dev** stage automatically, since the stage auto-deploys changes in the **master** branch. Also, since merging the pull request closes it, this will automatically remove the **pr2** stage.

![Show dev stage auto deploying](/assets/best-practices/creating-pull-request-environments/show-dev-stage-auto-deploying.png)

After the deployment completes and the **pr2** stage is removed, this is what your pipeline should look like:

![Show pull request stage removed](/assets/best-practices/creating-pull-request-environments/show-pull-request-stage-removed.png)

From GitHub's pull request screen, we can remove the **like** branch.

![Select remove branch in GitHub](/assets/best-practices/creating-pull-request-environments/select-remove-branch-in-github.png)

Back in Seed, this will trigger the **like** stage to be automatically removed.

![Show branch stage removed](/assets/best-practices/creating-pull-request-environments/show-branch-stage-removed.png)

After the removal is completed, your pipeline should now look like this.

![Show feature merged in dev stage](/assets/best-practices/creating-pull-request-environments/show-feature-merged-in-dev-stage.png)

Next, we are ready to promote our new feature to production.
