---
layout: post
title: Set up SSL
date: 2017-02-11 00:00:00
lang: ko 
description: AWS의 React.js 앱에서 SSL 또는 HTTPS를 사용하도록 설정하려고합니다. 그렇게하기 위해 우리는 AWS의 Certificate Manager 서비스를 사용하여 인증서를 요청할 것입니다. 그런 다음 CloudFront 배포판에서 새 인증서를 사용하려고합니다. 
context: true
comments_id: comments-for-set-up-ssl/133
ref: setup-ssl
---

이제 우리 응용 프로그램이 도메인을 통해 제공되고 있으므로 HTTPS로 전환하여 보안 기능을 추가해 보겠습니다. 인증서 관리자 덕분에 AWS를 사용하면 이 작업을 매우 쉽게 처리 할 수 있습니다.

### 인증서 요청

[AWS Console](https://console.aws.amazon.com)의 서비스 목록에서 **Certificate Manager**를 선택하십시오. 귀하가 **미국 동부 (버지니아 북부)** 지역에 있는지 확인하십시오. 이는 인증서가 이 지역의 [CloudFront와 함께 작동](http://docs.aws.amazon.com/acm/latest/userguide/acm-regions.html)해야하기 때문입니다.

![Certificate Manager 서비스 선택 화면](/assets/select-certificate-manager-service.png)

이것이 첫 번째 인증서인 경우 **인증서 프로비저닝 - 시작하기**를 눌러야합니다. 그렇지 않다면 상단에서 **인증서 요청**을 누르십시오.

![Certificate Manager 시작하기 화면](/assets/get-started-certificate-manager.png)

도메인 이름을 입력하십시오. **인증서에 다른 이름을 추가하십시오**를 누르고 도메인의 www 버전을 추가하십시오. 완료 되면 **검토 및 요청**을 누르십시오.

![인증서에 도메인 이름 추가하기](/assets/add-domain-names-to-certificate.png)

이제 도메인을 제어하는지 확인하려면 **DNS 검증** 방법을 선택하고 **검토**를 누르십시오.

![인증서 DNS 검증 선택 화면](/assets/select-dns-validation-for-certificate.png)

유효성 검사 화면에서 유효성을 검사하려는 두 도메인을 확장합니다.

![DNS 유효성 검사 상세정보 화면](/assets/expand-dns-validation-details.png)

Route 53을 통해 도메인을 제어하기 때문에 **Route 53에 레코드 만들기**를 사용하여 DNS 레코드를 직접 만들 수 있습니다.

![Route 53 dns 레코드 만들기 화면](/assets/create-route-53-dns-record.png)

그리고 **생성**을 눌러 레코드 생성을 확인하십시오.

![Route 53 dns 레코드 확인하기 화면](/assets/confirm-route-53-dns-record.png)

또한 다른 도메인에서도 이 작업을 수행해야합니다.

DNS 레코드를 생성하고 유효성을 검사하는 프로세스는 약 30 분이 소요될 수 있습니다.

다음으로 이 인증서를 CloudFront 배포판과 연결합니다.

### 인증서로 CloudFront 배포판 업데이트

배포판 목록에서 첫 번째 CloudFront Distribution을 열고 **Edit** 버튼을 누릅니다.

![CloudFront 배포판 선택 화면](/assets/select-cloudfront-Distribution.png)

이제 **SSL Certificate**를 **Custom SSL Certificate**로 전환하고 방금 만든 인증서를 드롭 다운에서 선택하십시오. 아래로 스크롤하여 **Yes, Edit**을 누르십시오.

![Custom SSL Certificate 선택 화면](/assets/select-custom-ssl-certificate.png)

그런 다음, 상단에서 **Behaviors** 탭으로 이동하십시오.

![Behaviors 탭 이동 화면](/assets/select-behaviors-tab.png)

그리고 이미 생성한 항목을 선택하고 **Edit**을 클릭합니다.

![Distribution Behavior 편집 화면](/assets/edit-distribution-behavior.png)

그런 다음 **Viewer Protocol Policy**을 **Redirect HTTP to HTTPS**으로 전환하십시오. 아래로 스크롤하여 **Yes, Edit**을 누르십시오.

![Switch Viewer Protocol Policy 화면](/assets/switch-viewer-protocol-policy.png)

이제 다른 CloudFront 배포판에서도 동일한 작업을 수행하십시오.

![Custom SSL Certificate 선택 화면](/assets/select-custom-ssl-certificate-2.png)

그러나 **Viewer Protocol Policy**은 **HTTP 및 HTTPS**로 그대로 두십시오. 이는 사용자가 www가 아닌 도메인의 HTTPS 버전으로 바로 이동하기를 원하기 때문입니다. 다시 방향을 바꾸기 전에 www 도메인의 HTTPS 버전으로 리디렉션하는 것과는 대조적입니다.

![www 배포판의 Viewer Protocol Policy 변경 미반영 화면](/assets/dont-switch-viewer-protocol-policy-for-www-distribution.png)

### S3 리디렉션 버킷 업데이트

마지막 챕터에서 만든 S3 리디렉션 버킷은 www가 아닌 도메인의 HTTP 버전으로 리디렉션됩니다. 추가로 리디렉션을 방지하려면 HTTPS 버전으로 전환해야합니다.

마지막 장에서 만든 S3 리디렉션 버킷을 엽니다. **속성** 탭으로 이동하여 **정적 웹 사이트 호스팅**을 선택하십시오.

![S3 리디렉트 버킷 속성 바꾸기 화면](/assets/open-s3-redirect-bucket-properties.png)

**프로토콜**을 **https**로 바꾸고 **저장**을 선택합니다.

![S3 리디렉트를 HTTPS 바꾸는 화면](/assets/change-s3-redirect-to-https.png)

이제 응용 프로그램은 HTTPS를 통해 도메인을 제공합니다.

![인증서 기반으로 앱 기동 화면](/assets/app-live-with-certificate.png)

다음으로 앱의 업데이트를 배포하는 과정을 살펴 보겠습니다.
