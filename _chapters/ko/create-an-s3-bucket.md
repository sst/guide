---
layout: post
title: Create an S3 Bucket
date: 2017-02-06 00:00:00
lang: ko
redirect_from:  /chapters/create-a-s3-bucket.html
description: S3를 사용하여 AWS에서 React.js 응용 프로그램을 호스팅합니다. 먼저 버킷 정책을 사용하여 S3 버킷을 구성하고 AWS 콘솔을 통해 정적 웹 호스팅을 활성화해야 응용 프로그램을 업로드할 수 있습니다.
context: true
comments_id: create-an-s3-bucket/48
ref: create-an-s3-bucket
---

노트 작성 앱을 호스팅하려면 S3에서 정적으로 제공 할 컨텐트를 업로드해야합니다. S3에는 서로 다른 유형의 파일을 구분하는 버킷(또는 폴더) 개념이 있습니다.

또한 정적 웹 사이트로 컨텐트를 호스팅하도록 버킷을 구성하고 공개적으로 액세스 할 수있는 URL을 자동으로 할당할 수 있습니다. 그럼 시작하겠습니다.

### 버킷 만들기 

먽, 콘솔[AWS Console](https://console.aws.amazon.com)에 로그인하고 서비스 목록에서 S3를 선택합니다.

![S3 서비스 선택 화면](/assets/select-s3-service.png)

**버킷 만들기**를 클릭하고 우리 앱을 위한 이름을 입력합니다. 그리고 **US East (N. Virginia) Region** 리전을 선택합니다. 우리는 앱 서비스를 위해 CDN을 사용할 예정이므로 해당 리전은 크게 중요하지 않습니다.

![S3 정적 웹사이트 호스팅을 위한 버킷 만들기 화면](/assets/create-s3-bucket-1-name.png)

**다음**을 클릭하여 옵션을 선택합니다.

![S3 정적 웹사이트 호스팅을 위한 버킷 옵션 설저하기 화면](/assets/create-s3-bucket-2-configure-options.png)

권한 설정 단계에서 모든 퍼블릭 액세스 차단의 **새 퍼블릭 버킷 정책 차단** 과 **임의의 퍼블릭 버킷 정책을 통해 부여된 버킷 및 객체에 대한 퍼블릭 및 교차 계정 액세스 차단** 선택을 취소하십시오. 버킷을 공개하는 것은 일반적인 보안 오류이지만 이 경우에는 버킷에서 앱 컨텐트를 제공하므로 버킷을 공개해야합니다.

![S3 정적 웹사이트 호스팅을 위한 버킷 권한 설정 화면](/assets/create-s3-bucket-3-permissions.png)

검토 화면에서 최종적으로 버킷을 생성하기 위해 **버킷 만들기**를 클릭합니다.

![S3 정적 웹사이트 호스팅을 위한 버킷 만들기 검토 화면](/assets/create-s3-bucket-4-review.png)

목록에서 새로 생성된 버킷을 클릭하고 **권한**을 클릭하여 권한 패널로 이동하십시오.

![AWS S3 정적 웹사이트 버킷 권한 설정 화면](/assets/select-bucket-permissions.png)

### 권한 추가하기

기본적으로 버킷은 공개적으로 액세스할 수 없으므로 S3 버킷 권한을 변경해야합니다. 권한 패널에서 **버킷 정책**을 선택하십시오.

![AWS S3 버킷 권한 추가 화면](/assets/add-bucket-policy.png)

<img class="code-marker" src="/assets/s.png" />편집기에 다음 버킷 정책을 추가하십시오. 여기서 `notes-app-client`는 S3 버킷의 이름입니다. 여기에 여러분의 버킷 이름을 사용하십시오. 

``` json
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadForGetBucketObjects",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::notes-app-client/*"]
    }
  ]
}
```

![버킷 정책 저장 화면](/assets/save-bucket-policy.png)

**저장**을 누르십시오.

### 정적 웹 호스팅 사용

그리고 마지막으로 생성한 버킷을 정적 웹 사이트로 전환해야합니다. 상단 패널에서 **속성** 탭을 선택하십시오.

![속성 탭 선택 화면](/assets/select-bucket-properties.png)

**정적 웹 사이트 호스팅**을 선택합니다.

![정정 웹 사이트 호스팅 선택 화면](/assets/select-static-website-hosting.png)

이제 **이 버킷을 사용하여 웹 사이트를 호스팅합니다** 와 `index.html`을 **색인 문서**와 **오류 문서**로 지정하십시오. 앱 자체의 React 핸들러에서 404 오류를 처리하기 때문에, 우리는 에러를 간단히 `index.html`에 리디렉션할 수 있습니다. 완료되면 **저장**을 클릭하십시오.

이 패널은 우리 앱이 어디에서 액세스 할 수 있는지 알려줍니다. AWS는 정적 웹 사이트의 URL을 할당합니다. 이 경우 우리에게 할당된 URL은`notes-app-client.s3-website-us-east-1.amazonaws.com`입니다.

![정적 웹 사이트 호스팅 속정 편집 화면](/assets/edit-static-web-hosting-properties.png)

이제 버킷이 모두 준비되었으므로 이제 컨텐트을 업로드 해 보겠습니다.
