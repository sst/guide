# Deploying services with dependency in phases

# How does service dependency affect deploying my app?

The short version is that:

- When you introduce a new dependency in your app you cannot deploy the services concurrently.
- However, if these services have been deployed before, you can deploy them concurrently.

### First deployment

If you are deploying the above app for the first time, you have to deploy `checkout-api` first, such that the export value exist, ie.  `dev-PurchasedTopicArn` if you are deploying to `dev` stage . Then deploy `confirmation-job` and `reset-cart-job`. If you were to deploy all three services concurrently, `confirmation-job` and `reset-cart-job` will fail with CloudFormation throwing the following error:
```
    confirmation-job - No export named dev-PurchasedTopicArn found.
```
It’s basically saying that the ARN referenced in its `serverless.yml` does not exist. That makes sense because we haven’t created it yet!

### Subsequent deployments

Once the three services have been successfully deployed, you can deploy them concurrently. This is because the referenced ARN is created after the first deployment.

### Adding new dependencies

Say you add a new SNS topic in `checkout-api`, and `confirmation-job` and `reset-cart-job` once again subscribe to the topic. The first deployment after the change, will again fail if all the services are deployed concurrently. You need to deploy `checkout-api` first, and then deploy `confirmation-job` and `reset-cart-job`.

# Managing deployment in phases

A mono repo app usually has multiple API services and multiple background services (ie. cron jobs, step functions, SNS/SQS subscribers). A common dependency pattern is that the jobs services depend on the API services, simply because the API services always response synchronously to user requests, and they in turn invoke the jobs to do more work.

So it is easier to visualize your services in phases. Deploy the services in each phase in parallel and deploy the phases sequentially. With Seed, we handle this using the concept of [Deploy Phases](https://seed.run/docs/configuring-deploy-phases) and to keep your builds fast, we [check if a service has been updated](https://seed.run/docs/deploying-monorepo-apps).
