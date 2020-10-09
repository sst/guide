---
layout: post
title: Set up the Serverless Framework
date: 2016-12-29 00:00:00
description: AWS Lambda 및 API Gateway를 사용하여 서버리스 백엔드 API를 만들려면 Serverless Framework (https://serverless.com)를 사용합니다. Serverless Framework는 개발자가 AWS 및 기타 클라우드 제공 업체에서 서버리스 앱을 만들고 관리 할 수 있도록 도와줍니다. 우리는 NPM 패키지에서 Serverless Framework CLI를 설치하고이를 사용하여 새로운 Serverless Framework 프로젝트를 만들 수 있습니다.
lang: ko
ref: setup-the-serverless-framework
context: true
code: backend
comments_id: set-up-the-serverless-framework/145
---

우리는 백엔드를 만들기 위해 [AWS Lambda](https://aws.amazon.com/lambda/)와 [Amazon API Gateway](https://aws.amazon.com/api-gateway/)를 사용합니다. AWS Lambda는 서버를 프로비저닝하거나 관리하지 않고 코드를 실행할 수있게 해주는 컴퓨팅 서비스입니다. 여러분이 사용하는 컴퓨팅 시간에 대해서만 비용을 지불합니다. 여러분의 코드가 실행되고 있지 않을 때는 무료입니다. 또한 API 게이트웨이를 사용하면 개발자가 API를 쉽게 작성, 게시, 유지 관리, 모니터링 및 보안을 적용할 수 있습니다. AWS Lambda와 API 게이트웨이를 손수 구성하는 것은 다소 번거롭 수 있습니다. 그래서 우리는 이를 돕기 위해 [Serverless Framework](https://serverless.com)를 사용할 것입니다.

Serverless Framework를 사용하면 개발자가 AWS Lambda에 배포할 독립 기능으로 백엔드 응용 프로그램을 배포 할 수 있습니다. Amazon API 게이트웨이를 사용하여 HTTP 요청에 응답하여 코드를 실행하도록 AWS Lambda를 자동으로 구성합니다.

이 장에서는 로컬 개발환경에서 Severless Framework를 설치할 것입니다.

### Serverless 설치하기

{%change%} Serverless를 전역으로 설치합니다.

``` bash
$ npm install serverless -g
```

위의 명령에는 JavaScript 용 패키지 관리자인 [NPM](https://www.npmjs.com)이 필요합니다. NPM 설치에 도움이 필요하면 [여기](https://docs.npmjs.com/getting-started/installing-node)의 안내를 따르십시오.

<img class="code-marker" src="/assets/s.png"/> 작업 디렉토리에서 Node.js 스타터를 사용하여 프로젝트를 생성하십시오. 다음 장에서이 스타터 프로젝트의 세부 사항을 살펴 보겠습니다.

``` bash
$ serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name notes-api
```

{%change%} 백앤드 API 프로젝트 디렉토리로 이동합니다.

``` bash
$ cd notes-api
```

이제 디렉토리에는 **handler.js** 및 **serverless.yml**과 같은 몇 개의 파일이 있어야합니다.

- **handler.js** 파일에는 AWS Lambda에 배포 될 서비스/기능의 실제 코드가 들어 있습니다.
- **serverless.yml** 파일에는 Serverless가 제공 할 AWS 서비스 구성 및 구성 방법이 포함되어 있습니다.

단위 테스트를 추가 할 수있는`tests/` 디렉토리도 있습니다.

### Node.js 패키지 인스톨하기 

이 스타터 프로젝트는 `package.json` 목록에서 볼 수 있듯이 몇 가지 의존성이 있습니다. 

{%change%} 프로젝트의 루트 경로에서 아래 명령어를 실행합니다.

``` bash
$ npm install
```

{%change%} 다음은 백앤드를 위해 특별한 몇 가지 패키지를 설치합니다.

``` bash
$ npm install aws-sdk --save-dev
$ npm install uuid --save
```

- **aws-sdk**를 사용하면 다양한 AWS 서비스와 통신할 수 있습니다.
- **uuid**는 고유 ID를 생성합니다. DynamoDB에 데이터를 저장하는 데 필요합니다.

여기서 구축할 스타터 프로젝트는 나중에 프론트 엔드 앱에서 사용할 JavaScript 버전을 사용할 수있게 해줍니다. 정확히 어떻게하는지 보도록하겠습니다.

