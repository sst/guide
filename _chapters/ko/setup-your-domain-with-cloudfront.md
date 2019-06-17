---
layout: post
title: Set up Your Domain with CloudFront
date: 2017-02-09 00:00:00
lang: ko 
description: React.js 애플리케이션을 AWS의 자체 도메인 이름으로 호스팅하려면 Route 53을 사용하여 도메인을 구입해야 합니다. 우리는 Alias Resource Record Set를 사용하여 도메인을 CloudFront Distribution으로 지정할 것입니다. 또한 IPv6을 지원하기 위해 AAAA 레코드 세트를 만들어야합니다. 
context: true
comments_id: set-up-your-domain-with-cloudfront/149
ref: set-up-your-domain-with-cloudfront
---

이제 CloudFront 배포를 운영에 올렸으므로 도메인을 설정하십시오. 서비스 목록의 Route 53으로 이동하여 [AWS 콘솔](https://console.aws.amazon.com)에서 도메인을 구입할 수 있습니다.

![Route 53 서비스 선택 화면](/assets/select-route-53-service.png)

### Route 53 도메인 구입하기

**도메인 등록**을 클릭하고 도메인을 입력합니다. 그리고 **변경**을 클릭합니다.

![사용 가능한 도메인 검색 화면](/assets/search-available-domain.png)

사용 가능한 도메인을 검색 후에 **장바구니에 추가**를 클릭합니다.

![도메인 장바구에 추가 화면](/assets/add-domain-to-cart.png)

화면 아래에 **계속** 버튼을 클릭합니다.

![연락처 세부 정보 화면](/assets/continue-to-contact-detials.png)

연락처 세부 정보를 입력하고 다시 **계속** 버튼을 클릭합니다.

![상세 정보를 확인 후 계속하기 화면](/assets/continue-to-confirm-detials.png)

마지막으로 상세 정보를 검토하고 **구매 완료**를 클릭해서 구매를 진행합니다.

![도메인 구매 확인 화면](/assets/confirm-domain-purchase.png)

다음으로 CloudFront Distribution에 대한 대체 도메인 이름을 추가합니다.

### CloudFront Distribution에 대한 대체 도메인 이름 추가하기

CloudFront Distribution의 세부 정보로 이동하여 **Edit**을 누르십시오.

![CloudFront Distribution 수정하기 화면](/assets/edit-cloudfront-distribution.png)

그리고 **Altenate Domain Names(CNAME)** 필드에 새 도메인 이름을 입력하십시오.

![대체 도메인 이름 지정 화면](/assets/set-alternate-domain-name.png)

아래로 스크롤해서 **Yes, Edit**을 클릭해서 변경 사항을 저장합니다.

![Yes edit CloudFront 변경 화면](/assets/yes-edit-cloudfront-changes.png)

다음으로 도메인을 CloudFront Distribution으로 지정해 보겠습니다.

### CloudFront Distribution으로 도메인 지정하기

Route53으로 돌아가서 **호스팅 영역** 버튼을 누릅니다. 기존 **호스팅 영역**이 없다면 **호스팅 영역 생성**을 클릭하여 **도메인 이름**을 추가하고 **퍼블릭 호스팅 영역**을 **유형**으로 선택하여 도메인을 생성해야합니다.

![Route53 호스트 존 선택화면](/assets/select-route-53-hosted-zones.png)

도메인 목록에서 여러분의 도메인을 선택하고 **레코드 세트 생성**을 클릭합니다.

![레코드 세트 생성하기 화면](/assets/select-create-record-set.png)

**Name** 필드는 비어있는 채로 도메인을(www가없는) CloudFront Distribution으로 가리켜야 하기 때문에 비워 둡니다.

![이름 필드를 비운 화면](/assets/leave-name-field-empty.png)

**별칭**을 **예**로 선택하십시오. 우리는 이것을 CloudFront 도메인으로 간단히 지정합니다.

![별칭을 예로 설정하는 화면](/assets/set-alias-to-yes.png)

**별칭 대상** 드롭 다운에서 CloudFront 배포를 선택하십시오.

![CloudFront Distribution 선택 화면](/assets/select-your-cloudfront-distribution.png)

마지막으로 신규 레코드를 추가하기 위해 **생성**을 클릭합니다.

![레코드 세트 추가하기 위한 생성 화면](/assets/select-create-to-add-record-set.png)

### IPv6 지원 추가하기 

CloudFront Distributions는 기본적으로 IPv6이 활성화되어 있어 AAAA 레코드도 만들어야 함을 의미합니다. 별칭 레코드와 정확히 같은 방식으로 설정됩니다.

**유형**으로 **AAAA - IPv6 주소**를 선택하는 것을 제외하고는 이전과 똑같은 설정으로 새 레코드 세트를 만드십시오.

![AAAA IPv6 레코드 세트 선택 화면](/assets/select-create-aaaa-ipv6-record-set.png)

**생성**을 클릭하여 AAAA 레코드 세트를 추가하십시오.

DNS 레코드를 업데이트하는데 약 1 시간이 걸릴 수 있지만 일단 완료되면 도메인을 통해 앱에 액세스 할 수 있어야합니다.

![신규 도메인으로 서비스 중인 앱 화면](/assets/app-live-on-new-domain.png)

다음으로, 앱에 www. 도메인도 연결하도록 합니다.
