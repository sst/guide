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

AWS Lambda는 최근 Node.js v8.10에 대한 지원을 추가했습니다. 뒷 부분에서 다룰 프론트 엔드 React 앱과 비교할 때 지원되는 구문은 약간 다릅니다. 프로젝트의 두 부분에서 유사한 ES 기능을 사용하는 것이 합리적입니다. 특히 우리는 핸들러 기능에서 ES 가져 오기/내보내기를 사용합니다. 이를 위해 [Babel](https://babeljs.io) 및 [Webpack 4](https://webpack.github.io)를 사용하여 코드를 번역합니다. Serverless Framework는 이를 자동으로 수행하는 플러그인을 지원합니다. 우리는 [serverless-webpack](https://github.com/serverless-heaven/serverless-webpack) 플러그인을 사용할 것입니다.

이 모든 것들은 이전 장에서 [`serverless-nodejs-starter`]({% link _chapters/serverless-nodejs-starter.md %})를 사용하여 설치되었습니다. 다음 몇 가지 이유로 이 스타터를 만들었습니다.

- 프론트 엔드 및 백엔드에서 비슷한 버전의 JavaScript 사용
- 번역 된 코드에 오류 메시지에 대한 올바른 줄 번호가 있는지 확인하기.
- 백엔드 API를 로컬에서 실행할 수 있습니다.
- 단위 테스트 지원 추가

우리가 `serverless install --url https://github.com/AnomalyInnovations/serverless-nodejs-starter --name my-project` 명령을 사용하여이 스타터를 설치했다는 것을 상기 해주십시오. 이것은 Serverless Framework에게 [starter](https://github.com/AnomalyInnovations/serverless-nodejs-starter)를 템플릿으로 사용하여 프로젝트를 생성하도록 지시합니다.

이 장에서는 이 작업을 수행하는 방법에 대해 빠르게 살펴보고 필요에 따라 나중에 변경하도록 하겠습니다.

### Serverless Webpack

ES 코드를 노드 v8.10 JavaScript로 변환하는 과정은 serverless-webpack 플러그인에 의해 수행됩니다. 이 플러그인은`serverless.yml`에 추가되었습니다. 좀 더 자세히 살펴 보겠습니다.

<img class="code-marker" src="/assets/s.png"/>`serverless.yml`을 열고 아래와 같이 기본값으로 대체하십시오.

``` yaml
service: notes-app-api

# serverless-webpack 플러그인을 사용하여 ES6을 가로 채기
plugins:
  - serverless-webpack
  - serverless-offline

# serverless-webpack 구성
# 외부 모듈에 대한 패키징 자동화 활성화
custom:
  webpack:
    webpackConfig: ./webpack.config.js
    includeModules: true

provider:
  name: aws
  runtime: nodejs8.10
  stage: prod
  region: us-east-1
```

`service` 옵션은 매우 중요합니다. 우리의 서비스를 `notes-app-api`라고 부릅니다. Serverless Framework는이 이름을 사용하여 AWS에 스택을 만듭니다. 즉, 이름을 변경하고 프로젝트를 배포하면 완전히 새로운 프로젝트가 만들어집니다.

포함되어있는`serverless-webpack` 플러그인에 주목하십시오. 또한 플러그인을 설정하는`webpack.config.js`도 있습니다.

`webpack.config.js`는 다음과 같습니다. 따로 수정하지 않아도됩니다. 그냥 훓어만 보십시오.

``` js
const slsw = require("serverless-webpack");
const nodeExternals = require("webpack-node-externals");

module.exports = {
  entry: slsw.lib.entries,
  target: "node",
     
  // 적절한 오류 메시지를위한 소스 맵 생성
  devtool: 'source-map',
  // 'aws-sdk'는 webpack과 호환되지 않으므로
  // 모든 노드 종속성을 제외합니다.
  externals: [nodeExternals()],
  mode: slsw.lib.webpack.isLocal ? "development" : "production",
  optimization: {
    // 코드를 최소화하고 싶지는 않습니다.
    minimize: false
  },
  performance: {
    // 진입 점에 대한 크기 경고 끄기
    hints: false
  },
  //모든 .js 파일에서 babel을 실행하고 node_modules을 건너 뜁니다.
  module: {
    rules: [
      {
        test: /\.js$/,
        loader: "babel-loader",
        include: __dirname,
        exclude: /node_modules/
      }
    ]
  }
};
```

이 설정의 주요 부분은`serverless-webpack` 플러그인의 일부인`slsw.lib.entries`를 사용하여 자동으로 생성하는`entry` 속성입니다. 그러면 자동으로 모든 핸드러 함수가 선택되어 패키지화됩니다. 우리는 또한 각각의 코드에 "babel-loader"를 사용하여 코드를 변형시킵니다. 여기서 주목해야 할 또 하나의 점은 Webpack이 우리의 aws-sdk 모듈을 번들 화하기를 원치 않기 때문에`nodeExternals`를 사용한다는 것입니다. aws-sdk는 Webpack과 호환되지 않습니다.

마지막으로 바벨 구성을 간단히 살펴 보겠습니다. 다시 말씀드리지만 아래 코드를 변경하지 않아도됩니다. 프로젝트 루트에서`.babelrc` 파일을 열면 다음과 같이 보입니다.

``` json
{
  "plugins": ["source-map-support", "transform-runtime"],
  "presets": [
    ["env", { "node": "8.10" }],
    "stage-3"
  ]
}
```
여기서 우리는 바벨에게 우리의 코드를 노드 v8.10로 변환하도록 지시하고있습니다.

이제 우리는 백엔드를 구축 할 준비가 되었습니다.

