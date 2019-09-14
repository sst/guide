---
layout: post
title: Add Support for ES6/ES7 JavaScript
date: 2016-12-29 12:00:00
redirect_from: /chapters/add-support-for-es6-javascript.html
description: AWS Lambda는 Node.js v8.10을 지원하므로 Serverless Framework 프로젝트에서 ES 가져 오기/내보내기를 사용하기 위해 Babel과 Webpack 4를 사용하여 코드를 추출해야합니다. 프로젝트에 serverless-webpack 플러그인을 사용하면됩니다. 이를 위해 serverless-nodejs-startter를 사용합니다.
lang: ko
ref: add-support-for-es6-es7-javascript
context: true
code: backend
comments_id: add-support-for-es6-es7-javascript/128
---

AWS Lambda는 최근 Node.js v8.10와 v10.x에 대한 지원을 추가했습니다. 뒷 부분에서 다룰 프론트 엔드 React 앱과 비교할 때 지원되는 구문은 약간 다릅니다. 프로젝트의 두 부분에서 유사한 ES 기능을 사용하는 것이 합리적입니다. 특히 우리는 핸들러 함수에서 ES import/export를 사용합니다. 이를 위해 [Babel](https://babeljs.io) 및 [Webpack 4](https://webpack.github.io)를 사용하여 코드를 트랜스파일링합니다. 또한, Webpack을 사용하면 Lambda 함수에서 사용된 코드만을 포함하여 Lambda 함수 패키지의 생성을 최적화할 수 있습니다. 이를 통하여 패키지의 크기가 줄고 콜드 스타트 시간이 감소할 수 있습니다. Serverless Framework는 이를 자동으로 수행하는 플러그인을 지원합니다. 우리는 유명한 플러그인 [serverless-webpack](https://github.com/serverless-heaven/serverless-webpack)의 확장인 [serverless-bundle](https://github.com/AnomalyInnovations/serverless-bundle)을 사용할 것입니다.

이 모든 것들은 이전 장에서 [`serverless-nodejs-starter`]({% link _chapters/serverless-nodejs-starter.md %})를 사용하여 설치되었습니다. 스타터 프로젝트를 만든 이유는 아래와 같습니다.

- Lambda 함수 패키지 생성의 최적화
- 프론트 엔드 및 백엔드에서 비슷한 버전의 JavaScript 사용
- 트랜스파일링된 코드에 오류 메시지에 대한 올바른 줄 번호가 있는지 확인하기
- 코드 린트(Lint) 단위 테스트 지원 추가
- 로컬에서 백엔드 API 실행이 가능하도록 하기
- Webpack 및 Babel 설정을 신경쓰지 않도록 하기

우리가 `serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name my-project` 명령을 사용하여 이 스타터를 설치했다는 것을 상기해주십시오. 이렇게 하면 Serverless Framework가 [starter](https://github.com/AnomalyInnovations/serverless-nodejs-starter)를 템플릿으로 사용하여 프로젝트를 생성해줍니다.

이 장에서는 이 작업을 수행하는 방법에 대해 빠르게 살펴보고 필요에 따라 나중에 변경하도록 하겠습니다.

### Serverless Webpack

ES 코드를 Node.js v8.10 JavaScript로 변환하는 과정은 serverless-bundle 플러그인에 의해 수행됩니다. 이 플러그인은`serverless.yml`에 추가되었습니다. 좀 더 자세히 살펴 보겠습니다.

<img class="code-marker" src="/assets/s.png" />`serverless.yml`을 열고 아래와 같이 기본값으로 대체하십시오.

``` yaml
service: notes-app-api

# 우리가 사용할 함수에 최적화된 패키지를 생성합니다
package:
  indivitually: true

plugins:
  - serverless-bundle # 우리의 함수를 Webpack으로 패키징합니다
  - serverless-offline

provider:
  name: aws
  runtime: nodejs8.10
  stage: prod
  region: us-east-1
```

`service` 옵션은 매우 중요합니다. 우리의 서비스는 `notes-app-api`라고 부르겠습니다. Serverless Framework는 이 이름을 사용하여 AWS에 스택을 만듭니다. 즉, 이름을 변경하고 프로젝트를 배포하면 완전히 새로운 프로젝트가 만들어집니다.

우리가 포함한 `serverless-bundle`과 `serverless-offline` 플러그인을 주목하시기 바랍니다. `serverless-bundle`은 위에서 설명한 바와 같습니다. [`serverless-offline`](https://github.com/dherault/serverless-offline)은 로컬 개발 환경을 구성하는 데에 유용한 플러그인입니다.

또한, 아래와 같은 옵션값들을 사용하겠습니다.

```yml
# 우리가 사용할 함수에 최적화된 패키지를 생성합니다
package:
  indivitually: true
```

Serverless 프레임워크는 기본값으로 당신의 어플리케이션에 포함되어있는 Lambda 함수들을 모두 포함하는 커다란 패키지를 생성합니다. 큰 크기의 Lambda 함수 패키지는 더 긴 콜드 스타트를 유발할 수 있습니다. `individually: true`로 설정하면, Serverless 프레임워크가 Lambda 함수 하나당 하나의 패키지를 각각 생성하게 됩니다. 이러한 설정은 Serverless-bundle(과 Webpack)과 함께 최적화된 패키지를 생성하는 데에 도움이 됩니다. 물론 빌드가 느려지겠지만, 성능 상의 이득이 훨씬 큰 의미가 있을 것입니다.

이제 우리는 백엔드를 구축 할 준비가 되었습니다.
