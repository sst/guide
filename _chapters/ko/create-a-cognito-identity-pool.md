---
layout: post
title: Create a Cognito Identity Pool
date: 2017-01-05 00:00:00
description: Amazon Cognito 연동 자격증명(Federated Identities)은 AWS 리소스를 보호하는 데 도움이됩니다. Cognito 사용자 풀은 서버리스 백엔드의 ID 제공 프로바이더로 사용할 수 있습니다. 사용자가 S3 버킷에 파일을 업로드하고 API 게이트웨이에 연결할 수 있게하려면 ID 풀을 만들어야합니다. IAM 정책에 S3 버킷의 이름을 지정하고 파일에 cognito-identity.amazonaws.com:sub 접두어를 붙입니다. 또한 API 게이트웨이 엔드포인트를 리소스로 추가할 것입니다.
lang: ko
ref: create-a-cognito-indentity-pool
context: true
comments_id: create-a-cognito-identity-pool/135
---

이전 장에서 백엔드 API를 배포했습니다. 우리는 이제 백엔드에 필요한 모든 조각을 거의 가지고 있습니다. 우리는 모든 사용자를 저장하고 로그인 및 가입에 도움을 줄 사용자 풀을 보유하고 있습니다. 또한 사용자가 메모를 첨부하여 파일을 업로드하는 데 사용할 S3 버킷이 있습니다. 이러한 모든 서비스를 안전한 방식으로 묶는 마지막 부분을 Amazon Cognito 연동 자격증명(Federated Identities)라고합니다.

Amazon Cognito 연동 자격증명은 개발자가 사용자에 대해 고유 자격증명을 만들고 연동 자격증명 공급자로 인증할 수있게합니다. 연동 자격증명을 사용하면 임시로 제한된 권한의 AWS 자격증을 획득하여 Amazon DynamoDB, Amazon S3 및 Amazon API Gateway와 같은 다른 AWS 서비스에 안전하게 액세스 할 수 있습니다.

이 장에서는 연동된 Cognito 자격증명 풀을 만들겠습니다. 우리는 사용자 풀을 자격증명 공급자로 이용할 예정입니다. Facebook, Google 또는 맞춤형 자격증명 공급자를 사용할 수도 있습니다. 사용자 풀을 통해 사용자가 인증되면 자격증명 풀이 IAM 역할을 사용자에게 연결합니다. 우리는 S3 버킷 및 API에 대한 액세스 권한을 부여하기 위해이 IAM 역할에 대한 정책을 정의합니다. 이것이 아마존의 자원 확보 방법입니다.

그럼 시작해보겠습니다.

###  풀(Pool) 만들기

[AWS 콘솔](https://console.aws.amazon.com)에서 서비스 목록 중에 **Cognito**를 선택합니다. 

![Cognito 서비스 선택 화면](/assets/cognito-identity-pool/select-cognito-service.png)

**자격 증명 풀 관리** 선택

![자격 증명 풀 관리 선택 화면](/assets/cognito-identity-pool/select-manage-federated-identities.png)

**자격 증명 풀 이름**을 입력합니다. 만일 이미 자격 증명 풀을 가지고 있다면, **새 자격 증명 풀 만들기**를 클릭하세요.

![Cognito 자격 증명 풀 정보 입력 화면](/assets/cognito-identity-pool/fill-identity-pool-info.png)

**인증 공급자**를 선택하고 **Cognito** 탭 아래에 [Cognito 사용자 풀 만들기]({% link _chapters/create-a-cognito-user-pool.md %}) 챕터에서 만들었던 사용자 풀의 **사용자 풀 ID**와 **App Client ID**를 입력합니다. **풀 생성**을 클릭합니다.

![인증 공급자 정보 입력 화면](/assets/cognito-identity-pool/fill-authentication-provider-info.png)

이제 Cognito 자격 증명 풀에서 가져온 임시 자격 증명이 있는 사용자가 액세스할 수 있는 AWS 리소스를 지정해야합니다.

**세부 정보 보기**를 선택하십시오. 두 개의 **역할 요약** 섹션이 확장되었습니다. 맨 위 섹션에는 인증 된 사용자의 권한 정책이 요약되어 있으며 아래 섹션에는 인증되지 않은 사용자의 권한 정책이 요약되어 있습니다.

상단 섹션에서 **정책 문서 보기**를 선택하십시오. 그런 다음 **편집**을 선택하십시오.

![정책 문서 편집 선택 화면](/assets/cognito-identity-pool/select-edit-policy-document.png)

먼저 문서를 읽어보라는 알림 메시지 창이 뜹니다. **확인**을 클릭해서 편집합니다.

![정책 편집 확인 버튼 선택 화면](/assets/cognito-identity-pool/select-confirm-edit-policy.png)

<img class="code-marker" src="/assets/s.png" />아래 정책을 편집화면에 추가합니다. 그리고 `YOUR_S3_UPLOADS_BUCKET_NAME`을 [S3 파일 업로드 버킷 만들기]({% link _chapters/create-an-s3-bucket-for-file-uploads.md %}) 챕터에서 만든 **버킷 이름**으로 대체합니다. 그리고 지난 장에서 여러분이 만든 API 배포시 확인한 `YOUR_API_GATEWAY_REGION` 와 `YOUR_API_GATEWAY_ID`을 입력합니다. 

여기에서는 `YOUR_S3_UPLOADS_BUCKET_NAME` 는 `notes-app-uploads`로, `YOUR_API_GATEWAY_ID` 는 `ly55wbovq4`, 그리고 `YOUR_API_GATEWAY_REGION` 는 `us-east-1`로 입력합니다.

``` json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::YOUR_S3_UPLOADS_BUCKET_NAME/private/${cognito-identity.amazonaws.com:sub}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "execute-api:Invoke"
      ],
      "Resource": [
        "arn:aws:execute-api:YOUR_API_GATEWAY_REGION:*:YOUR_API_GATEWAY_ID/*/*/*"
      ]
    }
  ]
}
```

S3 버킷과 관련된 블록에 대해 간단히 정리하면, 위의 정책에서 우리는 로그인 한 사용자에게`private/${cognito-identity.amazonaws.com:sub/}/`경로에 대한 액세스 권한을 부여합니다. 여기서 `cognito-identity.amazonaws.com:sub`는 인증된 사용자의 연동 자격 증명 ID(사용자 ID) 입니다. 따라서 사용자는 버킷 내의 자신의 폴더에만 액세스 할 수 있습니다. 이것이 각 사용자의 업로드를 보호하는 방법입니다.

요약하면 인증된 사용자가 두 가지 자원에 액세스 할 수 있음을 AWS에 알리 것입니다.

1. S3 버킷의 폴더(연동 자격 증명 ID명) 내부에 업로드된 파일들
2. API 게이트웨이를 사용하여 배포한 API

주의해야할 또 한 가지는 연동 자격 증명 ID가 우리의 자격 증명 풀에서 할당된 UUID라는 점입니다. 이것은 API를 만들 때 사용자 ID로 사용했던 ID (`event.requestContext.identity.cognitoIdentityId`)입니다.

**허용**을 선택하십시오.

![Cognito 자격 증명 풀 정책 저장 화면](/assets/cognito-identity-pool/submit-identity-pool-policy.png)

이제 Cognito 자격 증명 풀을 생성해야합니다. 자격 증명 풀 ID를 알아 보겠습니다.

왼쪽 패널에서 **대시보드**를 선택한 다음, 화면 우측에 위치한 **자격 증명 풀 편집** 버튼을 클릭하십시오.

![Cognito 자격 증명 풀 생성 화면](/assets/cognito-identity-pool/identity-pool-created.png)

나중에 사용하기 위해 **자격 증명 풀 ID**를 적어 두십시오.

![Cognito 자격 증명 풀 생성 화면](/assets/cognito-identity-pool/identity-pool-id.png)

이제 서버리스 API를 테스트하기 전에 Cognito 사용자 풀과 Cognito 자격 증명 풀을 간단하게 살펴보고 두 개념과 그 차이점에 대해 알아 보도록하겠습니다.
