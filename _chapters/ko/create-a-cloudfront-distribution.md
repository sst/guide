---
layout: post
title: Create a CloudFront Distribution
date: 2017-02-08 00:00:00
lang: ko
description: Amazon S3에서 호스팅되는 React.js 앱을 CDN을 통해 서비스하려면 CloudFront를 사용합니다. 우리는 CloudFront Distribution을 만들고 S3 Bucket을 가리킬 것입니다. 또한 AWS 콘솔의 "자동으로 객체 압축" 설정을 사용하여 Gzip 압축을 활성화할 예정입니다. React.js 앱이 올바른 HTTP 헤더로 응답하기 위해 사용자 오류 응답을 만듭니다.
context: true
comments_id: create-a-cloudfront-distribution/104
ref: create-a-cloudfront-distribution
---

S3에서 앱을 실행 했으므로 이제 CloudFront를 통해 전 세계에 서비스를 제공하십시오. 이렇게 하려면 AWS CloudFront Distribution을 만들어야합니다.

[AWS 콘솔](https://console.aws.amazon.com)의 서비스 목록에서 CloudFront를 선택하십시오.

![AWS CloudFront 서비스 화면](/assets/select-cloudfront-service.png)

**Create Distribution**을 선택합니다.

![Create Distribution 화면](/assets/create-cloudfront-distribution.png)

그리고 **Web** 섹션에서 **Get Started**를 클릭합니다.

![Get started 선택 화면](/assets/select-get-started-web.png)

Create Distribution 작성 양식에서 CloudFront를 통한 웹 배포를 위해 Origin Domain Name을 지정하여 시작해야 합니다. 이 필드는 우리가 앞서 만든 S3 버킷을 포함하여 몇 가지 옵션으로 미리 채워져 있습니다. 그러나 우리는 드롭 다운의 옵션을 선택하지 **않을** 것입니다. 이는 정적 웹 사이트로 설정된 것이 아닌 S3 버킷의 REST API 엔드포인트이기 때문입니다.

S3 버킷의 **정적 웹 호스팅** 패널에서 S3 웹 사이트 엔드포인트를 찾을 수 있습니다. 이전 챕터에서 이 작업을 설정했습니다. **Endpoint** 필드에 URL을 복사하십시오.

![S3 정적 웹 사이트 도메인 화면](/assets/s3-static-website-domain.png)

해당 URL을 **Origin Domain Name** 필드에 붙여 넣으십시오. 여기서는 `http://notes-app-client.s3-website-us-east-1.amazonaws.com` 입니다.

![Origin domain name 필드 입력 화면](/assets/fill-origin-domain-name-field.png)

이제 양식을 아래로 스크롤하여 **Compress Objects Automatically**을 **Yes**로 전환하십시오. 이렇게하면 압축 할 수있는 파일을 자동으로 Gzip으로 압축하여 앱 전송 속도를 높일 수 있습니다.

![자동으로 개체 압축 선택 화면](/assets/select-compress-objects-automatically.png)

다음으로, 아래로 스크롤해서 **Default Root Object**를 `index.html`로 설정합니다.

![Default root object 설정 화면](/assets/set-default-root-object.png)

그리고 마지막으로, **Create Distribution**을 클릭합니다.

![Create distribution 화면](/assets/hit-create-distribution.png)

AWS에 배포를 하려면 약간의 시간이  필요합니다. 그러나 일단 완료되면 목록에서 새로 생성 된 배포를 클릭하고 Domain Name을 찾아 새로운 CloudFront 배포를 찾을 수 있습니다.

![AWS CloudFront Distribution 도메인 이름 화면](/assets/cloudfront-distribution-domain-name.png)

그리고 브라우저에서 생성된 배포 주소를 접속하면 아래와 같이 서비스 중인 앱 화면을 보실 수 있어야합니다.

![CloudFront를 통해 서비스 중인 앱 화면](/assets/app-live-on-cloudfront.png)

여기서 마치기 전에 마지막으로해야 할 일이 있습니다. 현재 정적 웹 사이트는 오류 페이지로 `index.html`을 반환합니다. 우리는 S3 버킷을 만들었던 챕터에서 이것을 설정했습니다. 그러나 이렇게하면 HTTP 상태 코드 404가 반환됩니다. `index.html`을 반환하기를 원하지만 라우팅은 React Router에 의해 처리되기 때문에 404 HTTP 상태 코드를 반환하는 것은 의미가 없습니다. 이 문제 중 하나는 특정 회사 방화벽 및 프록시가 4xx 및 5xx 응답 유형을 차단하는 경향이 있다는 것입니다.

### 사용자 정의 에러 응답

따라서 사용자 정의 오류 응답을 작성하고 대신 상태 코드 200을 리턴 할 것입니다. 이 접근 방식의 단점은 React Router에서 경로가 없는 경우에도 정상적인 상태를 나타내는 200을 반환한다는 것입니다. 불행히도 이 문제를 해결할 방법은 없습니다. 이것은 CloudFront 또는 S3가 React Router의 경로를 인식하지 못하기 때문입니다.

사용자 정의 오류 응답을 설정하려면 D우리가 생성한 Distribution 에서 **Error Pages** 탭으로 이동하십시오.

![CloudFront Error Pages 화면](/assets/error-pages-in-cloudfront.png)

그리고 **Create Custom Error Response**를 클릭합니다.

![CloudFront에서 사용자 정의 에러 응답 만들기 화면](/assets/select-create-custom-error-response.png)

**HTTP Error Code**에 **404**를 선택하고 **Customize Error Response**를 선택하십시오. **Response Page Path**에 대해서는 `/index.html`을 입력하고 **HTTP Response Code**에는 **200**을 선택하십시오.

![사용자 정의 에러 응답 만들기 화면](/assets/create-custom-error-response.png)

그리고 **Create**을 누르십시오. 이것은 기본적으로 CloudFront에게 S3 버킷의 404 응답에 `index.html` 및 200 상태 코드로 응답하도록 지시합니다. 사용자 정의 오류 응답이 반영되려면 몇 분이 걸릴 것입니다.

다음으로 도메인을 CloudFront Distribution에 연결해 보겠습니다.
