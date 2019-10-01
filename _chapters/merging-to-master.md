# Final deploy

After local development is completed in the `recommendations` branch, before merging the branch into the `master` branch, make sure you don't have any un-pushed commits. Because you have been deploying locally while developing, if you have un-push commits, you want to do a git push and let Seed do a clean deployment of all services. Then do a final clean test before merging back to `master`.

# Merge to master

Once final test looks good, merge the pull request. Go to GitHub's pr page and select **Merge pull request**.

![](/assets/best-practices/merging-to-master-1.png)

Go back to Seed, this will trigger a deployment in the `dev` stage automatically, since the stage auto-deploys changes in the `master` branch. Also, since by merging the pull request, the pull request is closed. This automatically removes the `pr6` stage.

![](/assets/best-practices/merging-to-master-2.png)

After the deployment completes and the `pr6` stage is removed, the pipeline looks like

![](/assets/best-practices/merging-to-master-3.png)
