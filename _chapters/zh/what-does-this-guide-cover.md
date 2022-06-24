---
layout: post
ref: what-does-this-guide-cover
title: 本指南涵盖哪些内容?
date: 2016-12-22 00:00:00
lang: zh
ref: what-does-this-guide-cover
context: true
comments_id: what-does-this-guide-cover/83
---

为了逐步了解构建 web 应用程序所涉及的主要概念，我们将要构建一个叫做 [**Scratch**](https://demo2.sst.dev) 的简单笔记程序。

![Completed app desktop screenshot](/assets/completed-app-desktop.png)

<img alt="Completed app mobile screenshot" src="/assets/completed-app-mobile.png" width="432" />

这是一个单页面应用，完全使用 JavaScript 编写的 serverless API 驱动。这里是全部的[后端]({{ site.backend_github_repo }})和[前端]({{ site.frontend_github_repo }})源代码。它是一个相对简单的应用，但我们将要满足如下需求：

- 应该允许用户注册和登录他们的账户
- 用户应该能够创建包含某些内容的笔记
- 每一篇笔记还能够上传一个文件作为附件
- 允许用户修改他们的笔记和附件
- 用户还能够删除他们的笔记
- 该应用应该能处理信用卡付款
- 该应用应该通过自定义域名上的 HTTPS 提供服务
- 后端 API 需要是安全的
- 该应用需要响应及时

我们将使用 AWS 的平台来构建它。我们可能会进一步扩展并涵盖一些其他的平台，但我们认为 AWS 的平台将会是一个不错的起点。

### 技术 & 服务

我们将使用以下的技术和服务来构建我们的 serverless 应用。

- 使用 [Lambda][Lambda] & [API Gateway][APIG] 来构建我们的 serverless API
- 使用 [DynamoDB][DynamoDB] 作为我们的数据库
- 使用 [Cognito][Cognito] 做用户身份认证和保护我们的 API
- 使用 [S3][S3] 托管我们的应用和上传的文件
- 使用 [CloudFront][CF] 提供我们的应用
- 使用 [Route 53][R53] 来解析我们的域名
- 使用 [Certificate Manager][CM] 提供 SSL
- 使用 [React.js][React] 编写我们的单页面应用
- 使用 [React Router][RR] 来路由
- 使用 [Bootstrap][Bootstrap] 作为 UI 工具包
- 使用 [Stripe][Stripe] 处理信用卡付款
- 使用 [Seed][Seed] 自动化部署 Serverless 应用
- 使用 [Netlify][Netlify] 自动化部署 React 应用  
- 使用 [GitHub][GitHub] 托管我们的工程仓库

我们将使用以上服务的 **免费套餐**。因此你应该免费注册 AWS 以获取它们。当然，这不适用于购买一个新域名来托管你的应用。当在 AWS 上创建账户的时候，你需要绑定一个信用卡账户。
因此，如果你恰巧要创建超过我们在此教程中涵盖的资源，那你最终可能会被收取费用。

尽管上面列出的内容可能看起来令人生畏，但我们正在努力确保完成本指南后，你将可以构建一个 **真正的**，**安全的**，和**全功能的** web 应用。不用担心，我们会随时帮助你！

### 要求

你需要 [Node v8.10+ and NPM v5.5+](https://nodejs.org/en/)。你还需要有一些如何使用命令行的基本知识。 

### 本指南是如何组织的

本指南分为两个单独的部分，它们都是相对独立的。第一部分介绍了基础知识，第二部分介绍了一些高级主题已经自动设置的方法。我们在2017年初发布了本指南的第一部分。Serverless 栈社区已经发展壮大，我们的很多读者已经使用本指南中描述的设置来构建驱动他们业务的应用。

因此，我们决定扩展该指南，给它增加第二部分。这是针对打算在项目中使用此设置的人们的。它使第一部分中的所有手工步骤自动化，帮助你创建一个准生产级工作流，你可以使用到你所有的 serverless 项目中。这是我们在两部分中介绍的内容。

#### 第一部分

创建笔记应用并进行部署。我们涵盖了所有的基础知识。每个服务都是手工创建的。这是按顺序介绍的内容：

对于后端:

- 配置你的 AWS 账户
- 使用 DynamoDB 创建你的数据库
- 设置 S3 进行文件上传
- 设置 Cognito 用户池来管理用户账户
- 设置 Cognito 身份池以保护我们的文件上传
- 设置 Serverless 框架以与 Lambda 和 API Gateway 一起使用
- 编写各种后端 API

对于前端:

- 使用 Create React App 来设置我们的项目
- 使用 Bootstrap 增加 favicons，字体和 UI 工具包
- 使用 React-Router 来设置路由
- 使用 AWS Cognito SDK 来实现用户注册和登录
- 插入后端 API 以管理我们的笔记应用 
- 使用 AWS JS SDK 来上传文件 
- 创建一个 S3 桶来上传我们的应用
- 配置 CloudFront 以提供我们的应用
- 使用 Route 53 将我们的域名指向 CloudFront
- 设置 SSL 以通过 HTTPS 提供我们应用的服务

#### 第二部分

面对希望将 Serverless 栈用于日常项目的人们，我们将第一部分中所有的步骤进行了自动化。这里是按顺序涵盖的内容：
We automate all the steps from the first part. Here is what is covered in order.

对于后端:

- 通过代码配置 DynamoDB
- 通过代码配置 S3
- 通过代码配置 Cognito 用户池
- 通过代码配置 Cognito 身份池
- Serverless 框架中的环境变量
- 使用 Stripe API
- 在 Serverless 框架中使用秘钥
- Serverless 中的单元测试
- 使用 Seed 进行自动部署
- 通过 Seed 配置自定义域名
- 通过 Seed 监控部署

对于前端

- Create React App 中的环境变量
- 在 React 中接受信用卡支付
- 使用 Netlify 进行自动部署
- 通过 Netlify 配置自定义域名

我们认为，这将会为你在构建全栈准生产级 serverless 应用方面奠定良好的基础。如果你希望我们涵盖任何其他的概念和技术，请在我们的论坛上告知我们。

[Cognito]: https://aws.amazon.com/cognito/
[CM]: https://aws.amazon.com/certificate-manager
[R53]: https://aws.amazon.com/route53/
[CF]: https://aws.amazon.com/cloudfront/
[S3]: https://aws.amazon.com/s3/
[Bootstrap]: http://getbootstrap.com
[RR]: https://github.com/ReactTraining/react-router
[React]: https://facebook.github.io/react/
[DynamoDB]: https://aws.amazon.com/dynamodb/
[APIG]: https://aws.amazon.com/api-gateway/
[Lambda]: https://aws.amazon.com/lambda/
[Stripe]: https://stripe.com
[Seed]: https://seed.run
[Netlify]: https://netlify.com
[GitHub]: https://github.com
