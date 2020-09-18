---
layout: post
title: Configure AWS Amplify
date: 2017-01-12 12:00:00
lang: ko 
ref: configure-aws-amplify
description: React 앱에서 AWS Amplify를 구성하기 위해 AWS 리소스의 정보를 사용하려고합니다. 앱을 처음 로드 할 때 Amplify.configure() 메소드를 호출합니다. 
context: true
comments_id: configure-aws-amplify/151
---

React 앱이 우리가 만든 AWS 리소스(튜토리얼의 백엔드 섹션)와 대화할 수 있도록 하기 위해 [AWS Amplify](https://github.com/aws/aws-amplify) 라이브러리를 사용합니다. 

AWS Amplify는 백엔드에 쉽게 연결할 수 있도록 몇 가지 간단한 모듈(인증, API 및 저장소)을 제공합니다. 시작하겠습니다.

### AWS Amplify 설치하기

{%change%} 작업 디렉토리에서 다음 명령을 실행합니다.

``` bash
$ npm install aws-amplify --save
```

NPM 패키지를 설치하면 `package.json`에 의존성이 추가됩니다.

### Config 만들기

먼저 우리가 만든 모든 리소스를 참조 할 수 있도록 앱의 구성 파일을 만들어 보겠습니다.

{%change%} `src/config.js` 파일을 만들고 다음 내용을 추가합니다. 

``` coffee
export default {
  s3: {
    REGION: "YOUR_S3_UPLOADS_BUCKET_REGION",
    BUCKET: "YOUR_S3_UPLOADS_BUCKET_NAME"
  },
  apiGateway: {
    REGION: "YOUR_API_GATEWAY_REGION",
    URL: "YOUR_API_GATEWAY_URL"
  },
  cognito: {
    REGION: "YOUR_COGNITO_REGION",
    USER_POOL_ID: "YOUR_COGNITO_USER_POOL_ID",
    APP_CLIENT_ID: "YOUR_COGNITO_APP_CLIENT_ID",
    IDENTITY_POOL_ID: "YOUR_IDENTITY_POOL_ID"
  }
};
```
여기에서 다음을 대체해야합니다.

1. [파일 업로드를위한 S3 버킷 생성]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) 챕터에서 S3 버킷 이름 및 리전을 나타내는 `YOUR_S3_UPLOADS_BUCKET_NAME` 및 `YOUR_S3_UPLOADS_BUCKET_REGION` 값을 대체합니다. 여기서는`notes-app-uploads`와`us-east-1`입니다.

2. [API 배포] ({% link _chapters/deploy-the-apis.md %}) 챕터에서 설명한 `YOUR_API_GATEWAY_URL` 및 `YOUR_API_GATEWAY_REGION` 값을 대체합니다. 여기에서 URL은`https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod`이고 리전은 `us-east-1`입니다.

3. Cognito **Pool Id**, **App Client id** 및 [Cognito 사용자 풀 만들기]({% link _chapters/create-a-cognito-user-pool.md %}) 챕터를 참조하여 `YOUR_COGNITO_USER_POOL_ID`, `YOUR_COGNITO_APP_CLIENT_ID` 및 `YOUR_COGNITO_REGION` 값을 대체합니다.

4. [Cognito ID 풀 만들기] ({% link _chapters/create-a-cognito-identity-pool.md %}) 챕터의 **자격 증명 풀 ID**를 참조하여 `YOUR_IDENTITY_POOL_ID` 값을 대체합니다.

### AWS Amplify 추가하기

다음으로 AWS Amplify를 설정합니다.

{%change%} `src/index.js`의 헤더에 다음 내용을 추가하여 import합니다.

``` coffee
import Amplify from "aws-amplify";
```

그리고 위에서 만든 config를 불러옵니다.

{%change%} 역시 `src/index.js` 헤더에 다음 내용을 추가합니다.

``` coffee
import config from "./config";
```

{%change%} 그리고 AWS Amplify를 초기화합니다. `src/index.js`의`ReactDOM.render` 행 위에 다음을 추가하십시오.

``` coffee
Amplify.configure({
  Auth: {
    mandatorySignIn: true,
    region: config.cognito.REGION,
    userPoolId: config.cognito.USER_POOL_ID,
    identityPoolId: config.cognito.IDENTITY_POOL_ID,
    userPoolWebClientId: config.cognito.APP_CLIENT_ID
  },
  Storage: {
    region: config.s3.REGION,
    bucket: config.s3.BUCKET,
    identityPoolId: config.cognito.IDENTITY_POOL_ID
  },
  API: {
    endpoints: [
      {
        name: "notes",
        endpoint: config.apiGateway.URL,
        region: config.apiGateway.REGION
      },
    ]
  }
});
```

여기에 몇 가지 참고 사항이 있습니다.

- Amplify는 Cognito를 `Auth`, S3을 `Storage`, API Gateway를 `API`라고 부릅니다.

- Auth에 대한 `mandatorySignIn` 플래그는 true로 설정되어 있습니다. 사용자들이 앱과 상호 작용하기 전에 로그인해야 하기 때문입니다.

- `name : "notes"`는 Amplify에 기본적으로 우리의 API의 이름을 지정하도록하고 있습니다. Amplify를 사용하면 앱에서 사용할 여러 API를 추가 할 수 있습니다. 우리의 경우, 전체 백엔드는 단 하나의 API입니다.

- `Amplify.configure()`는 상호 작용하고자하는 다양한 AWS 리소스를 설정하는 것입니다. 여기서는 구성과 관련하여 특별한 설정을 하지 않습니다. 따라서 필요치 않은 것일 수도 있지만 설정을 초기화하기 위한 것이니 기억해두십시오.

다음으로 로그인 및 회원 가입에 대해 알아보겠습니다.
