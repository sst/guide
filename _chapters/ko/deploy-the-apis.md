---
layout: post
title: Deploy the APIs
date: 2017-01-04 00:00:00
description: serverless deploy 명령을 사용하면 Serverless Framework를 사용하여 AWS Lambda 및 API Gateway에 배포 할 수 있습니다. 이 명령을 실행하면 배포된 API 엔드포인트와 AWS 영역의 목록이 표시됩니다. 그리고 개별 람다 함수를 업데이트하고자 할 때에는 serverless deploy function 명령을 실행할 수 있습니다.
lang: ko
ref: deploy-the-apis
context: true
comments_id: deploy-the-apis/121
---

이제 API가 완성되었으니 배포를 진행합니다.

{%change%} 현재 작업 디렉토리에서 아래 명령어를 실행합니다.

``` bash
$ serverless deploy
```

만일 AWS SDK를 위해 여러개의 프로파일을 가지고 있다면, 아래와 같이 그 중 하나를 명시해야만 합니다.

``` bash
$ serverless deploy --aws-profile myProfile
```

여기서`myProfile`은 사용할 AWS 프로파일의 이름입니다. Serverless에서 AWS 프로파일을 사용하는 방법에 대한 자세한 정보가 필요하면 [AWS 다중 프로파일 구성하기]({% link _chapters/configure-multiple-aws-profiles.md %}) 챕터를 참조하십시오.

이 명령의 출력 하단에 **서비스 정보**가 있습니다.

``` bash
Service Information
service: notes-api
stage: prod
region: us-east-1
api keys:
  None
endpoints:
  POST - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes
  GET - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  GET - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes
  PUT - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
  DELETE - https://ly55wbovq4.execute-api.us-east-1.amazonaws.com/prod/notes/{id}
functions:
  notes-api-prod-create
  notes-api-prod-get
  notes-api-prod-list
  notes-api-prod-update
  notes-api-prod-delete
```

여기에는 작성된 API 엔드포인트 목록이 있습니다. 프런트엔드를 생성하고 나서 나중에 사용할 예정이기 때문에 이러한 엔드포인트 주소를 기록해 두십시오. 또한 이 엔드포인트에서 리전과 ID를 기록해두면 다음 장에서 사용할 수 있습니다. 여기서 `us-east-1`은 API 게이트웨이 리전이고`ly55wbovq4`는 API 게이트웨이 ID입니다.

### 단일 함수 배포

모든 함수를 배포하지 않고 하나의 API 엔드포인트만을 배포하려는 경우가 있습니다. 'serverless deploy function` 명령은 전체 배포주기를 거치지 않고 개별 기능을 배포합니다. 이는 우리가 변경 한 사항만을 배포하는 훨씬 빠른 방법입니다.

예를 들어 목록 함수를 다시 배포하려면 다음을 실행할 수 있습니다.

``` bash
$ serverless deploy function -f list
```

API를 테스트하기 전에 마지막으로 설정해야할 사항이 하나 있습니다. 지금까지 작성한 AWS 리소스에 사용자가 안전하게 액세스할 수 있도록해야합니다. Cognito 자격증명 풀 설정에 대해 살펴 보겠습니다.
