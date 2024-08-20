---
layout: post
title: What Is Infrastructure as Code
date: 2018-02-26 00:00:00
lang: en
description: Infrastructure as Code or IaC is a process of automating the management of infrastructure through code, rather than doing it manually through a console or user interface.
ref: what-is-infrastructure-as-code
comments_id: what-is-infrastructure-as-code/161
---

[SST]({{ site.sst_url }}){:target="_blank"} converts your infrastructure code into a series of API calls to your cloud providers. Behind the scenes it uses [Pulumi](https://www.pulumi.com/){:target="_blank"} and [Terraform](https://www.terraform.io/){:target="_blank"}, more on this below. Your SST config is a description of the infrastructure that you are trying to create as a part of your project. In our case we'll be defining Lambda functions, API Gateway endpoints, DynamoDB tables, S3 buckets, etc.

While you can configure this using the [AWS console](https://aws.amazon.com/console/){:target="_blank"}, you'll need to do a whole lot of clicking around. It's much better to configure our infrastructure programmatically.

This general pattern is called **Infrastructure as code** and it has some massive benefits. Firstly, it allows us to completely automate the entire process. All you need is a config and a CLI to create your entire app. Secondly, it's not as error prone as doing it by hand.

Additionally, describing our entire infrastructure as code allows us to create multiple environments with ease. For example, you can create a dev environment where you can make and test all your changes as you work on it. And this can be kept separate from the production environment that your users are interacting with.

### Terraform

[Terraform](https://www.terraform.io/){:target="_blank"} is a large open source project that maintains _providers_ for all the cloud providers out there. Each provider includes resources that allow you to define almost everything the cloud provider has.

Terraform uses something called [HCL](https://developer.hashicorp.com/terraform/language/syntax/configuration) to define resources. For example, here's what the Terraform definition of a DynamoDB table looks like.

```hcl
resource "aws_dynamodb_table" "example" {
  name         = "example-table"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "sort_key"
    type = "N"
  }

  hash_key = "id"
  range_key = "sort_key"

  tags = {
    Name        = "example-table"
    Environment = "production"
  }
}
```

### Pulumi

One of the problems with the definition above is that as you work with more complex applications, your definitions start to get really large.

And while HCL (or YAML, or JSON) are easy to get started, it can be hard to reuse and compose them. To fix this [Pulumi](https://www.pulumi.com/){:target="_blank"} takes these providers and translates them into TypeScript (and other programming languages).

So in Pulumi the same DynamoDB would look something like this.

```ts
import * as aws from "@pulumi/aws";

const table = new aws.dynamodb.Table("exampleTable", {
  attributes: [
    { name: "id", type: "S" },
    { name: "sort_key", type: "N" },
  ],
  hashKey: "id",
  rangeKey: "sort_key",
  billingMode: "PAY_PER_REQUEST",
  tags: {
    Name: "example-table",
    Environment: "production",
  },
});
```

### Problems with traditional IaC

Traditional IaC, like the Terraform and Pulumi definition above, are made up of low level resources. This has a couple of implications:

1. You need to understand how each of these low level resources work. You need to know what the properties of a resource does.
2. You need a lot of these low level resources. For example, to deploy a Next.js app on AWS, you need around 70 of these low level resources.

This makes IaC really intimidating for most developers. Since you need very specific AWS knowledge to even deploy a simple CRUD app. As a result, IaC has been traditionally only used by DevOps or Platform engineers.

Additionally, traditional IaC tools don't help you with local development. They are only concerned with how you define and deploy your infrastructure. 

To fix this, we created SST. SST has high level components that wrap around these resources with sane defaults, so creating a Next.js app is as simple as.

```ts
new sst.aws.Nextjs("MyWeb");
```

And it comes with a full local development environment with the `sst dev` command.

### Working with IaC

If you have not worked with IaC before, it might feel unfamiliar at first. But as long as you remember a couple of things you'll be fine.

1. SST **automatically manages** the resources in AWS defined in your app.
2. You don’t need to **make any manual changes** to them in your AWS Console.

You can learn more about the [SST workflow]({{ site.sst_url }}/docs/workflow){:target="_blank"}.

Now we are ready to create our first SST app.
