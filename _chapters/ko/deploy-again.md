---
layout: post
title: Deploy Again
date: 2017-02-14 00:00:00
lang: ko 
description: S3 및 CloudFront에서 호스팅되는 React.js 앱에 업데이트를 배포하려면 S3에 앱을 업로드하고 CloudFront 캐시를 무효화해야합니다. AWS CLI에서 “aws cloudfront create-invalidation” 명령을 사용하여 이 작업을 수행 할 수 있습니다. “npm run deploy”를 실행하여 이러한 단계를 자동화하려면 이 명령을 추가하여 package.json에 사전 배포, 배포 및 사후 배포를 수행합니다.
context: true
comments_id: deploy-again/138
ref: deploy-again
---

이제 앱을 약간 변경 했으므로 업데이트를 배포해 보겠습니다. 참고로 업데이트를 배포 할 때마다 반복해야하는  프로세스입니다.

### 앱 빌드 

먼저 앱을 제작하여 앱을 준비해 봅시다. 작업 디렉토리에서 다음을 실행하십시오.

``` bash
$ npm run build
```

이제 앱이 빌드되고 `build/` 디렉토리에 준비되었으므로 S3에 배포해 보겠습니다.

### S3에 업로드

작업 디렉토리에서 다음을 실행하여 S3 버킷에 앱을 업로드하십시오. `YOUR_S3_DEPLOY_BUCKET_NAME`을 [S3 버킷 생성하기]({% link _chapters/create-an-s3-bucket.md %}) 챕터에서 생성한 S3 버킷으로 바꿔야합니다.

``` bash
$ aws s3 sync build/ s3://YOUR_S3_DEPLOY_BUCKET_NAME --delete
```

여기에 `--delete` 플래그가 있음을 주목하십시오. 이것은 이번에 업로드하지 않은 버킷에 있는 모든 파일을 삭제하도록 S3에게 명령합니다. Create React App은 빌드할 때 고유한 번들을 생성하며 이 플래그가 없으면 이전 빌드의 모든 파일을 유지하게됩니다.

변경 사항은 S3에 게시되어야합니다.

![S3에서 라이브로 앱이 반영되는 화면](/assets/app-updated-live-on-s3.png)

이제 CloudFront가 업데이트된 버전의 앱을 제공하는지 확인하기 위해 CloudFront 캐시를 무효화합니다.

### CloudFront 캐시 무효화

CloudFront를 사용하면 객체 경로를 전달하여 배포본의 객체를 무효화할 수 있습니다. 그러나 와일드 카드 (`/*`)를 사용하여 단일 명령으로 전체 배포를 무효화 할 수도 있습니다. 이는 앱의 새 버전을 배포할 때 권장됩니다.

이렇게하려면 CloudFront 배포판의 **두 가지 모두**의 **배포 ID**가 필요합니다. CloudFront 배포판 목록에서 배포판을 클릭하면 가져올 수 있습니다.

![CloudFront 배포판 ID 화면](/assets/cloudfront-distribution-id.png)

이제 AWS CLI를 사용하여 두 배포본의 캐시를 무효화 할 수 있습니다. `YOUR_CF_DISTRIBUTION_ID`와 `YOUR_WWW_CF_DISTRIBUTION_ID`을 위에있는 것과 바꾸십시오.

``` bash
$ aws cloudfront create-invalidation --distribution-id YOUR_CF_DISTRIBUTION_ID --paths "/*"
$ aws cloudfront create-invalidation --distribution-id YOUR_WWW_CF_DISTRIBUTION_ID --paths "/*"
```

이는 도메인의 www 버전과 www가 아닌 버전 모두에 대한 배포를 무효화합니다. **Invalidations** 탭을 클릭하면 무효화 요청이 처리되는 것을 볼 수 있습니다.

![CloudFront 무효화 진행 화면](/assets/cloudfront-invalidation-in-progress.png)

완료하는데 몇 분이 걸릴 수 있습니다. 그러나 일단 완료되면 앱의 업데이트 된 버전이 게시되어야합니다.

![앱 업데이트 운영 반영 화면](/assets/app-update-live.png)

모두 완료되었습니다. 이렇게 업데이트를 배포하기 위해 실행할 수있는 일련의 명령들이 있습니다. 하나의 명령으로 이를 처리할 수 있도록 신속하게 작업해 보겠습니다.

### Deploy 명령 추가

NPM을 사용하면 `package.json`에`deploy` 명령을 추가할 수 있습니다.

<img class="code-marker" src="/assets/s.png" />`package.json`에서 `eject` 위에 `scripts` 블럭을 다음 내용으로 추가합니다.

``` coffee
"predeploy": "npm run build",
"deploy": "aws s3 sync build/ s3://YOUR_S3_DEPLOY_BUCKET_NAME --delete",
"postdeploy": "aws cloudfront create-invalidation --distribution-id YOUR_CF_DISTRIBUTION_ID --paths '/*' && aws cloudfront create-invalidation --distribution-id YOUR_WWW_CF_DISTRIBUTION_ID --paths '/*'",
```

`YOUR_S3_DEPLOY_BUCKET_NAME`, `YOUR_CF_DISTRIBUTION_ID`, 그리고 `YOUR_WWW_CF_DISTRIBUTION_ID` 값을 위에서 입력했던 값과 바꾸십시오.

Windows 사용자의 경우 `postdeploy`가 다음과 같은 오류를 반환하면...

```
An error occurred (InvalidArgument) when calling the CreateInvalidation operation: Your request contains one or more invalid invalidation paths.
```

`/*`에 따옴표가 없는지 확인하십시오.

``` coffee
"postdeploy": "aws cloudfront create-invalidation --distribution-id YOUR_CF_DISTRIBUTION_ID --paths /* && aws cloudfront create-invalidation --distribution-id YOUR_WWW_CF_DISTRIBUTION_ID --paths /*",
```

이제 업데이트를 배포할 때 프로젝트 루트에서 다음 명령을 실행하기만하면됩니다. 앱을 빌드하고 S3에 업로드하고 CloudFront 캐시를 무효화합니다.

``` bash
$ npm run deploy
```

이제 앱이 완성되었습니다. 그리고 여기까지가 Part I의 끝입니다. 다음 챕터에서는 이 스택을 자동화하여 향후 프로젝트에 사용할 수있는 방법을 살펴 보겠습니다. [AWS Amplify를 사용하는 Cognito의 Facebook 로그인]({% link _chapters/facebook-login-with-cognito-using-aws-amplify.md %}) 챕터에서 Facebook 로그인을 추가하는 방법을 살펴볼 수도 있는데, 모두 지금까지 Part I에서 다루었던 것을 토대로 진행됩니다.
