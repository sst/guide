---
layout: post
title: Deploying Multiple Services in Serverless
description:
date: 2018-04-02 18:00:00
context: true
comments_id: 
---

Over the last few chapters we have:

- [Learned how to link multiple Serverless services using CloudFormation cross-stack references]({% link _chapters/cross-stack-references-in-serverless.md %})
- [Created our DynamoDB table as a Serverless service]({% link _chapters/dynamodb-as-a-serverless-service.md %})
- [Created an S3 bucket as a Serverless service]({% link _chapters/s3-as-a-serverless-service.md %})
- [Looked at how to use the same API Gateway domain and resources across multiple Serverless services]({% link _chapters/api-gateway-domains-across-services.md %})
- [Created a Serverless service for Cognito to authenticate and authorize our users]({% link _chapters/cognito-as-a-serverless-service.md %})

Now we can finally look at how to deploy our services. The addition of cross-stack references to our services means that we have some built-in dependencies in our services. This means that we need to deploy some services before we deploy certain others.

### Service Dependencies

Following is a list of the services we created:

```
database
uploads
notes
users
auth
```

And based on our cross-stack references the dependencies look like:

```
database > notes > users

uploads > auth
notes
```

Where the `a > b` symbolizes that service `a` needs to be deployed before service `b`. To break it down in detail:

- The `users` API service relies on the `notes` API service for the API Gateway cross-stack reference.

- The `users` and `notes` API services rely on the `database` service for the DynamoDB cross-stack reference.

- And the `auth` service relies on the `uploads` and `notes` service for the S3 bucket and API Gateway cross-stack references respectively.

Now there are some intricacies here but that is the general idea.

### Multi-Service Deployments

Given the rough dependency graph above, you can script your CI/CD pipeline to ensure that your automatic deployments follow these rules. There are a few ways to simplify this process.

It is very likely that your `auth`, `database`, and `uploads` service don't get changed very often and that you might need to follow some strict policies in your team to make sure no haphhazard changes are made to it. So by separating out these resources into their own services (like we have done in the past few chapters) you can carry out updates to these services by using a manual approval step as a part of the deployment process. This leaves the API services in your stack that need to be deployed in order once and can later be automated.

It should also be said that while you won't be able to automatically deploy using [Seed](https://seed.run) as we talked about in [Part II of this guide](/#part-2). We are working on a better way to handle this and feel free to [get in contact with us if you are interested](mailto:contact@seed.run).

### Environments

A quick word of handling environments across these services. The services that we have created can be easily re-created for multiple [environments or stages]({% link _chapters/stages-in-serverless-framework.md %}). A good standard practise is to have a _dev_, _staging_, and _prod_ environment. And it makes sense to replicate all your services across these three environments.

However, when you are working on a new feature or you want to give a developer on your team their own environment, it might not make sense to replicate all of your services across them. It is more common to only replicate the API services as you create multiple _development_ environments.

### Mono-Repo vs Multi-Repo

Finally, when considering where to house these services in your repository, it is worth looking at how much code is shared across them. Typically, your _infrastructure_ services (`database`, `uploads` and `auth`) don't share any code between them. In fact they probably don't have any code in them to begin with. These services can be put in their own repos. While the API services that might share some code (request and response handling) can be placed in the same repo and follow [the mono-repo approach from the previous chapter]({% link _chapters/organizing-serverless-projects.md %}).

This combined way of using the multi-repo and mono-repo strategy also makes sense when you think about how we deploy them. As we looked at above, the _infrastructure_ services are probably going to be deployed manually and with caution. While the API services will be autamated. So you can automate deployments (using [Seed](https://seed.run) or your own CI) for the mono-repo services and handle the others ones as a special case.

### Conclusion

Hopefully these series of chapters have given you a sense of how to structure large Serverless applications using CloudFormation cross-stack references. And the [example repo]({{ site.backend_mono_github_repo }}) gives you a clear working demostration of the concepts we've covered. Give the above setup a try and leave us your feedback in the comments.

