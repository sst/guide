---
layout: post
title: Deploy to S3
date: 2017-02-07 00:00:00
lang: ko 
description: 운영환경에서 React.js 응용 프로그램을 사용하려면 Create React App의 빌드 명령을 사용하여 응용 프로그램의 프로덕션 빌드를 만듭니다. React.js 앱을 AWS의 S3 Bucket에 업로드하려면 AWS CLI s3 sync 명령을 사용합니다. 
context: true
comments_id: deploy-to-s3/134
ref: deploy-to-s3
---

S3 Bucket이 생성되었으므로 앱의 asset을 업로드 할 준비가되었습니다.

### 앱 구축

Create React App은 배포를 위해 앱을 패키지화하는 등 다양한 준비과정을 처리할 수있는 편리한 방법을 제공합니다. 작업 디렉토리에서 다음 명령을 실행하십시오.

``` bash
$ npm run build
```

이것은 모든 asset을 패키지화하고 `build/` 디렉토리에 저장합니다.

### S3에 업로드

이제 배포하려면 다음 명령을 실행하십시오. 여기서 `YOUR_S3_DEPLOY_BUCKET_NAME`은 [S3 버킷 생성하기]({% link _chapters/create-an-s3-bucket.md %}) 챕터에서 생성한 S3 버킷 이름입니다.

``` bash
$ aws s3 sync build/ s3://YOUR_S3_DEPLOY_BUCKET_NAME
```

이 명령은 S3의 버킷과 `build/` 디렉토리를 동기화합니다. [AWS 콘솔](https://console.aws.amazon.com/console/home)의 S3 섹션으로 이동하여 방금 업로드한 파일이 버킷에 있는지 확인하십시오.

![S3 업로드하기 화면](/assets/uploaded-to-s3.png)

그리고 앱은 S3에 위치해 있어야 합니다. 만일 지정된 URL(여기서는 [http://notes-app-client.s3-website-us-east-1.amazonaws.com](http://notes-app-client.s3-website-us-east-1.amazonaws.com))을 방문하면 바로 볼 수 있습니다.

![S3에서 실행되는 앱 화면](/assets/app-live-on-s3.png)

다음으로, 글로벌 서비스를 위한 CloudFront 설정을 진행하겠습니다.
