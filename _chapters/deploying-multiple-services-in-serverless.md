---
layout: post
title: Deploying Multiple Services in Serverless
description: To deploy multiple Serverless services that are using CloudFormation cross-stack references, we need to ensure that we deploy them in the order of their dependencies.
date: 2018-04-02 18:00:00
context: true
code: mono-repo
comments_id: deploying-multiple-services-in-serverless/410
---

Over the last few chapters we have looked at how to:

- [Link multiple Serverless services using CloudFormation cross-stack references]({% link _chapters/cross-stack-references-in-serverless.md %})
- [Create our DynamoDB table as a Serverless service]({% link _chapters/dynamodb-as-a-serverless-service.md %})
- [Create an S3 bucket as a Serverless service]({% link _chapters/s3-as-a-serverless-service.md %})
- [Use the same API Gateway domain and resources across multiple Serverless services]({% link _chapters/api-gateway-domains-across-services.md %})
- [Create a Serverless service for Cognito to authenticate and authorize our users]({% link _chapters/cognito-as-a-serverless-service.md %})

All this is available in a [sample repo that you can deploy and test]({{ site.backend_mono_github_repo }}).

Now we can finally look at how to deploy our services. The addition of cross-stack references to our services means that we have some built-in dependencies. This means that we need to deploy some services before we deploy certain others.

### Service Dependencies

Following is a list of the services we created:

```
database
uploads
notes
users
auth
```

And based on our cross-stack references the dependencies look roughly like:

```
database > notes > users

uploads > auth
notes
```

Where the `a > b` symbolizes that service `a` needs to be deployed before service `b`. To break it down in detail:

- The `users` API service relies on the `notes` API service for the API Gateway cross-stack reference.

- The `users` and `notes` API services rely on the `database` service for the DynamoDB cross-stack reference.

- And the `auth` service relies on the `uploads` and `notes` service for the S3 bucket and API Gateway cross-stack references respectively.

Hence to deploy all of our services we need to follow this order:

1. `database`
2. `uploads`
3. `notes`
4. `users`
5. `auth`

Now there are some intricacies here but that is the general idea.

### Multi-Service Deployments

Given the rough dependency graph above, you can script your CI/CD pipeline to ensure that your automatic deployments follow these rules. There are a few ways to simplify this process.

It is very likely that your `auth`, `database`, and `uploads` service don't change very often. You might also need to follow some strict policies across your team to make sure no haphazard changes are made to it. So by separating out these resources into their own services (like we have done in the past few chapters) you can carry out updates to these services by using a manual approval step as a part of the deployment process. This leaves the API services. These need to be deployed manually once and can later be automated.

### Service Dependencies in Seed

[Seed](/) has a concept of [Deploy Phases](https://seed.run/docs/configuring-deploy-phases) to handle service dependencies.

You can configure this by heading to the app settings and hitting **Manage Deploy Phases**.

![Hit Manage Deploy Phases screenshot](/assets/mono-repo/hit-manage-deploy-phases.png)

Here you'll notice that by default all the services are deployed concurrently.

![Default Deploy Phase screenshot](/assets/mono-repo/default-deploy-phase.png)

Note that, you'll need to add your services first. To do this, head over to the app **Settings** and hit **Add a Service**.

![Click Add Service screenshot](/assets/mono-repo/click-add-service.png)

We can configure our service dependencies by adding the necessary deploy phases and moving the services around.

![Edit Deploy Phase screenshot](/assets/mono-repo/edit-deploy-phase.png)

And when you deploy your app, the deployments are carried out according to the deploy phases specified.

![Deploying with Deploy Phase screenshot](/assets/mono-repo/deploying-with-deploy-phase.png)

### Environments

A quick word of handling environments across these services. The services that we have created can be easily re-created for multiple [environments or stages]({% link _chapters/stages-in-serverless-framework.md %}). A good standard practice is to have a _dev_, _staging_, and _prod_ environment. And it makes sense to replicate all your services across these three environments.

However, when you are working on a new feature or you want to give a developer on your team their own environment, it might not make sense to replicate all of your services across them. It is more common to only replicate the API services as you create multiple _dev_ environments.

### Mono-Repo vs Multi-Repo

Finally, when considering how to house these services in your repository, it is worth looking at how much code is shared across them. Typically, your _infrastructure_ services (`database`, `uploads` and `auth`) don't share any code between them. In fact they probably don't have any code in them to begin with. These services can be put in their own repos. Whereas the API services that might share some code (request and response handling) can be placed in the same repo and follow the mono-repo approach outlined in the [Organizing Serverless Projects chapter]({% link _chapters/organizing-serverless-projects.md %}).

This combined way of using the multi-repo and mono-repo strategy also makes sense when you think about how we deploy them. As we stated above, the _infrastructure_ services are probably going to be deployed manually and with caution. While the API services can be automated (using [Seed](https://seed.run) or your own CI) for the mono-repo services and handle the others ones as a special case.

### Conclusion

Hopefully these series of chapters have given you a sense of how to structure large Serverless applications using CloudFormation cross-stack references. And the [example repo]({{ site.backend_mono_github_repo }}) gives you a clear working demonstration of the concepts we've covered. Give the above setup a try and leave us your feedback in the comments.

