---
layout: post
title: Set up WWW Domain Redirect
date: 2017-02-10 00:00:00
lang: ko 
description: AWS에서 React.js 응용 프로그램에 대한 www 도메인 버전을 만들려면 apex(또는 naked) 도메인으로 리디렉션해야 합니다. 리디렉션 되는 도메인을 만들려면 새 S3 버킷을 만들고 AWS 콘솔의 정적 웹 사이트 호스팅 섹션에서 "리디렉션 요청"옵션을 활성화하십시오. 그리고이를 위해 CloudFront Distribution을 만들고 www 도메인을 가리켜 야합니다. 
context: true
comments_id: set-up-www-domain-redirect/142
ref: setup-www-domain-redirect
---

www와 www가 아닌 도메인에 대해서는 많은 논란이 있고 양쪽에는 장점이 있습니다. 우리는 다른 도메인(이 경우에는 www)을 설정하고 원래 도메인으로 리디렉션하는 방법을 설명 할 것입니다. 리디렉션을 수행하는 이유는 검색 엔진에 도메인의 한 버전만 검색 결과로 표시하기를 원하기 때문입니다. www 도메인을 기본값으로 사용하는 것을 선호한다면이 단계를 맨 처음 도메인을 만들었던 마지막 도메인 (www가 아닌 도메인)으로 바꾸기 만하면 됩니다.

도메인의 www 버전을 만들고 리디렉션하도록 하려면 새 S3 Bucket과 새로운 CloudFront Distribution을 만들 것입니다. 이 새로운 S3 버킷은 S3 버킷에있는 리다이렉션 기능을 사용하여 메인 도메인으로 리다이렉트하면 됩니다.

먼저 새로운 S3 리디렉션 버킷을 만들어 보겠습니다.

### S3 리디렉트 버킷 만들기 

[AWS 콘솔](https://console.aws.amazon.com)을 통해 **새 S3 버킷**을 만드십시오. 이름은 중요하지 않지만 두 가지를 구별하는 데 도움이 되는 것을 선택합니다. 다시 말하지만 이 단계에서는 별도의 S3 버킷이 필요하며 이전에 만든 원래 버킷을 사용할 수 없습니다.

![S3 리디렉트 버킷 만들기 화면](/assets/create-s3-redirect-bucket.png)

다음 단계를 따르고 기본값을 그대로 둡니다.

![S3 리디렉트 버킷 만들기 기본설정 화면](/assets/use-defaults-to-create-bucket.png)

이제 새로운 버킷의 **속성**의로 이동하여 **정적 웹 사이트 호스팅**을 클릭하십시오.

![정적 웹 사이트 호스팅 설정화면](/assets/select-static-website-hosting-2.png)

그러나 지난 번과 달리 **요청리 디렉션** 옵션을 선택하고 리디렉션할 도메인을 입력합니다. 이것은 지난 챕터에서 설정한 도메인입니다.

또한 나중에 필요하므로 **Endpoint**를 복사하십시오.

![리디렉션 요청 선택 화면](/assets/select-redirect-requests.png)

**저장**을 클릭하여 변경하십시오. 다음으로 이 S3 리디렉션 버킷을 가리 키도록 CloudFront Distribution을 생성합니다.

### CloudFront 배포 만들기

**신규 CloudFront 배포**를 작성하십시오. 그리고 위 단계에서 S3 **Endpoint**를 **Origin Domain Name**으로 복사하십시오. 드롭 다운에서 **사용하지 않는** 것을 확인하십시오. 여기서는 `http://www-notes-app-client.s3-website-us-east-1.amazonaws.com`입니다.

![Origin domain name 설정 화면](/assets/set-origin-domain-name.png)

**Alternate Domain Names**으로 스크롤하여 여기에 도메인 이름의 www 버전을 사용하십시오.

![대체 도메인 이름 설정 화면](/assets/set-alternate-domain-name-2.png)

그리고 **Create Distribution** 클릭.

![배포 만들기 클릭 화면](/assets/hit-create-distribution.png)

마지막으로 www 도메인을이 CloudFront Distribution으로 지정합니다.

### WWW 도메인에서 CloudFront 배포 지정하기

Route 53에서 도메인으로 이동하여 **레코드 세트 생성**을 클릭하십시오.

![레코드 세트 생성 선택 화면](/assets/select-create-record-set-2.png)

이번에는 **이름**으로 `www`를 채우고 **별칭**을 **Yes**로 선택하십시오. **별칭 대상** 드롭 다운에서 새로운 CloudFront 배포를 선택하십시오.

![레코드 세트 상세 정보 입력 화면](/assets/fill-in-record-set-details.png)

### IPv6 지원 추가 

이전과 마찬가지로 IPv6 지원을 위해 AAAA 레코드를 추가해야 합니다.

**유형**으로 **AAAA - IPv6 주소**를 선택한 것을 제외하고는 이전과 완전히 동일한 설정으로 새 레코드 세트를 만듭니다.

![AAAA IPv6 레코드 세트 상세 정보 입력 화면](/assets/fill-in-aaaa-ipv6-record-set-details.png)

이제 다 됐습니다! DNS를 전파 할 시간을 기다립니다. 도메인의 www 버전을 방문하면 www가 아닌 버전으로 리디렉션됩니다.

다음으로 SSL을 설정하고 도메인에 HTTPS 지원을 추가합니다.
