---
layout: post
title: Manage Environments in Create React App
date: 2018-03-19 00:00:00
lang: ko
description: Create React App에서 새로운 환경을 구성하기 위해 사용자 정의 환경 변수를 작성합니다. 이것을 빌드 프로세스의 일부로 사용하고 우리가 목표로 삼고있는 환경을 기반으로 구성을 설정합니다.
context: true
comments_id: manage-environments-in-create-react-app/182
ref: manage-environments-in-create-react-app
---

우리는 백엔드 섹션에서 serverless 백엔드 API를 위한 두 가지 환경 (dev와 prod)을 만들었습니다. 이 장에서는 Frontend Create React App을 프론트엔드에 연결하도록 구성 할 것입니다.

현재 앱이 어떻게 구성되어 있는지 살펴 보겠습니다. 우리의 `src/config.js`는 모든 백엔드 리소스에 정보를 저장합니다.

``` js
export default {
  MAX_ATTACHMENT_SIZE: 5000000,
  s3: {
    REGION: "us-east-1",
    BUCKET: "notes-app-uploads"
  },
  apiGateway: {
    REGION: "us-east-1",
    URL: "https://5by75p4gn3.execute-api.us-east-1.amazonaws.com/prod"
  },
  cognito: {
    REGION: "us-east-1",
    USER_POOL_ID: "us-east-1_udmFFSb92",
    APP_CLIENT_ID: "4hmari2sqvskrup67crkqa4rmo",
    IDENTITY_POOL_ID: "us-east-1:ceef8ccc-0a19-4616-9067-854dc69c2d82"
  }
};
```

우리는 앱을 **dev**에 **푸시**할 때 백엔드의 개발 환경에 연결하고 **prod**는 운영 환경에 연결하도록 변경해야합니다. 물론 더 많은 환경을 추가할 수는 있지만 지금은 이것들만 추가해 보겠습니다.

### React Create App의 환경 변수

React 앱은 정적인 단일 페이지 앱입니다. 즉, 특정 환경에 대해 **build**가 작성되면 해당 환경이 계속 유지됩니다.

[Create React App](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#adding-custom-environment-variables)은 빌드 시스템에서 만들어진 사용자 정의 환경 변수를 지원합니다. 사용자 환경 변수를 설정하려면 Create React App 빌드 프로세스를 시작하는 동안 설정하십시오.

``` bash
$ REACT_APP_TEST_VAR=123 npm start
```

여기서 `REACT_APP_TEST_VAR`는 커스텀 환경 변수이며 값 `123`으로 설정합니다. app에서는이 변수에 `process.env.REACT_APP_TEST_VAR`로 접근 할 수 있습니다. 그래서 응용 프로그램에서 다음 줄은... :

``` js
console.log(process.env.REACT_APP_TEST_VAR);
```

`123`을 콘솔에 출력할겁니다.

이러한 변수는 빌드하는 동안 임베디드됩니다. 또한 `REACT_APP_`으로 시작하는 변수들만이 앱에 내장되어 있습니다. 다른 모든 환경 변수는 무시됩니다.

### Stage 환경 변수

우리의 목적을 위해 `REACT_APP_STAGE`라는 환경 변수를 사용합시다. 이 변수는 `dev` 와 `prod` 값을 취합니다. 그리고 기본적으로 `dev`로 설정되어 있습니다. 이제 우리는 config로 이것을 재 작성할 수 있습니다.

<img class="code-marker" src="/assets/s.png" />`src/config.js`를 다음 내용으로 대체합니다.

``` js
const dev = {
  s3: {
    REGION: "YOUR_DEV_S3_UPLOADS_BUCKET_REGION",
    BUCKET: "YOUR_DEV_S3_UPLOADS_BUCKET_NAME"
  },
  apiGateway: {
    REGION: "YOUR_DEV_API_GATEWAY_REGION",
    URL: "YOUR_DEV_API_GATEWAY_URL"
  },
  cognito: {
    REGION: "YOUR_DEV_COGNITO_REGION",
    USER_POOL_ID: "YOUR_DEV_COGNITO_USER_POOL_ID",
    APP_CLIENT_ID: "YOUR_DEV_COGNITO_APP_CLIENT_ID",
    IDENTITY_POOL_ID: "YOUR_DEV_IDENTITY_POOL_ID"
  }
};

const prod = {
  s3: {
    REGION: "YOUR_PROD_S3_UPLOADS_BUCKET_REGION",
    BUCKET: "YOUR_PROD_S3_UPLOADS_BUCKET_NAME"
  },
  apiGateway: {
    REGION: "YOUR_PROD_API_GATEWAY_REGION",
    URL: "YOUR_PROD_API_GATEWAY_URL"
  },
  cognito: {
    REGION: "YOUR_PROD_COGNITO_REGION",
    USER_POOL_ID: "YOUR_PROD_COGNITO_USER_POOL_ID",
    APP_CLIENT_ID: "YOUR_PROD_COGNITO_APP_CLIENT_ID",
    IDENTITY_POOL_ID: "YOUR_PROD_IDENTITY_POOL_ID"
  }
};

// Default to dev if not set
const config = process.env.REACT_APP_STAGE === 'prod'
  ? prod
  : dev;

export default {
  // Add common config values here
  MAX_ATTACHMENT_SIZE: 5000000,
  ...config
};
```

다른 버전의 자원을 [Seed를 통해 배포]({% link _chapters/deploying-through-seed.md %}) 챕터의 자원으로 바꿔야합니다.

`REACT_APP_STAGE`가 설정되어 있지 않으면 dev 환경을 기본값으로 설정한다는 것에주의하십시오. 이것은 현재의 빌드 프로세스(`npm start` 와 `npm run build`)가 `dev` 환경을 기본값으로한다는 것을 의미합니다. 그리고 두 환경에 공통적인 `MAX_ATTACHMENT_SIZE`와 같은 설정 값에 대해서는 다른 섹션에서 다루겠습니다.

우리가 앱을 개발하고 배포한다면, 그것들은 개발 모드에서 봐야하고 백엔드의 dev 버전에 연결됩니다. 배포 프로세스는 아직 변경하지 않았지만 다음 장에서 프런트엔드 배포를 자동화할 때 이를 변경하겠습니다.

우리는 prod 버전에 아직 대해 걱정할 필요가 없습니다. 그러나 예를 들어 앱의 prod 버전을 만들고 싶다면 다음을 실행해야합니다.

``` bash
$ REACT_APP_STAGE=prod npm run build
```

또는 윈도우즈에서 다음을 실행합니다.
``` bash
set "REACT_APP_STAGE=prod" && npm start
```


### 변경 사항 커밋 

Git에 변경된 파일을 커밋합니다.

``` bash
$ git add .
$ git commit -m "Configuring environments"
```

다음으로 앱에 설정 페이지를 추가해 보겠습니다. 사용자가 서비스 비용 지불을 위해 설정하는 곳입니다!
