---
layout: post
title: Netlify에서 사용자 정의 도메인 설정
date: 2018-03-28 00:00:00
lang: ko
description: Netlify 및 AWS에서 사용자 정의 도메인으로 React 응용 프로그램을 구성하려면 Route 53 DNS에서 Netlify를 가리켜 야합니다. 새 Netlify 프로젝트에 대해 새 레코드 세트를 작성하고 A 레코드 및 CNAME을 추가하십시오. 
context: true
comments_id: custom-domains-in-netlify/191
ref: custom-domains-in-netlify
---

첫 배포가 완료되었으므로 Netlify를 통해 앱의 맞춤 도메인을 구성 해 보겠습니다.

---

**Part I의 독자에게 보내는 메모**

다음 섹션에서는 [Part I](/#part-1)을 독자적으로 작성하고 아래 사용자 정의 도메인을 처음부터 설정한다고 가정합니다. 그러나 Part I을 방금 완성한 경우 다음 두 가지 옵션을 사용할 수 있습니다.

1. 새 사용자 정의 도메인 구성

   Part I의 도메인이 `https://notes-app.my-domain.com`과 같다고 가정 해 보겠습니다. 다음 섹션에서는 `https://notes-app-2.my-domain.com`과 같은 것을 설정할 수 있습니다. 이것은 이전에 구성된 내용을 변경하지 않기 때문에 선호되는 옵션입니다. 여기까지 튜토리얼에서 데모 응용 프로그램을 위해 우리가 작업한 내용들입니다. [Part I 버전](https://demo.serverless-stack.com)과 [Part II 버전](https://demo2.serverless-stack.com)을 볼 수 있습니다. 단점은 frontend React 앱의 두 가지 버전이 있다는 것입니다.

2. 이전 도메인 바꾸기

이 가이드를 통해 앱을 만드는 방법을 배우는 대신 바로 앱을 만들 수 있습니다. 그렇다면 프런트엔드의 두 가지 버전이 주위에 운영되는 것은 이해가 되지 않습니다. Part 1에서 생성된 도메인 연결을 해제 해야합니다. 그렇게하려면 [apex 도메인]({% link _chapters/setup-your-domain-with-cloudfront.md %}#point-domain-to-cloudfront-distribution)과 [www 도메인]({% link _chapters/setup-www-domain-redirect.md %})에서 만든 Route53 레코드 세트를 제거하십시오.

위의 두 가지 옵션에 대해 잘 모르거나 질문이있는 경우, 이 챕터의 맨 아래에 있는 토론 스레드에 의견을 게시하십시오.

---

시작하겠습니다!

### Netlify 사이트 이름 선택

Netlify의 프로젝트 페이지에서 **Site setting**을 누릅니다.

![Netlify Site settings 클릭 화면](/assets/part2/netlify-hit-site-settings.png)

**Site information** 아래에 **Change site name** 클릭.

![사이트 이름 변경 클릭 화면](/assets/part2/hit-change-site-name.png)

사이트 이름은 글로벌이므로 고유한 사이트 이름을 선택하십시오. 여기서는 `serverless-stack-2-client`를 사용하고 있습니다. **Save**를 누르십시오.

![사이트 이름 변경화면 저장](/assets/part2/save-change-site-name.png)

즉, Netlify 사이트 URL은 이제 `https://serverless-stack-2-client.netlify.com`이 될 것입니다. 이것을 이 챕터의 뒷 부분에서 사용할 예정이므로 기록해둡니다.

### Netlify의 도메인 설정

다음으로 측면 패널에서 **Domain management**를 클릭하십시오.

![Domain management 선택 화면](/assets/part2/select-domain-management.png)

그리고 **Add custom domain**를 클릭.

![ Add custom domain 클릭화면](/assets/part2/click-add-custom-domain.png)

우리 도메인의 이름을 입력하십시오. 예를 들어, `demo-serverless-stack.com` 일 수 있습니다. **Save**를 누르십시오.

![사용자 정의 도메인 입력 화면](/assets/part2/enter-custom-domain.png)

그러면 여러분이 도메인의 소유자인지 확인하고 새로 추가할 것인지 묻는 메시지가 나타납니다. **Yes, add domain**을 클릭하십시오.

![루트 도메인 추가 화면](/assets/part2/add-root-domain.png)

다음으로 **Check DNS configuration**을 클릭합니다.

![check DNS configuration 클릭 화면](/assets/part2/hit-check-dns-configuration.png)

Route53을 통해 도메인을 설정하는 방법이 표시됩니다.

![DNS 구성 대와 화면](/assets/part2/dns-configuration-dialog.png)

### Route 53에서 도메인 설정

이를 위해 [AWS 콘솔](https://console.aws.amazon.com/)로 돌아갑니다. 그리고 서비스 목록에서 Route 53을 검색합니다.

![Route 53서비스 선택화면](/assets/part2/select-route-53-service.png)


**Hosted zones** 클릭.

![Route 53 hosted zones 클릭 화면](/assets/part2/select-route-53-hosted-zones.png)

그리고 설정하고자 하는 도메인을 선택합니다.

![Route 53 도메인 선택 화면](/assets/part2/select-route-53-domain.png)

**Create Record Set** 클릭 화면.

![첫 번째 Route 53 레코드 세트 생성화면](/assets/part2/create-first-route-53-record-set.png)

**Type**으로 **A - IPv4 address** 와 **Value**으로 **104.198.14.52** 입력하고 **Create**을 클릭합니다. [Netlify에서 사용자 정의 도메인 추가하기 문서](https://www.netlify.com/docs/custom-domains/)에서 IP 주소를 가져옵니다.

![A 레코드 추가 화면](/assets/part2/add-a-record.png)

다음으로 **Create Record Set**을 다시 클릭합니다.

**Name**을 `www`, **Type**을 **CNAME - Canonical name**으로, 그리고 위에서 언급한 Netlify 사이트 이름입니다. 여기서는 `https://serverless-stack-2-client.netlify.com`입니다. **Create**을 누르십시오.

![CNAME 레코드 추가 화면](/assets/part2/add-cname-record.png)

그리고 DNS가 업데이트되도록 30분을 기다립니다.

### SSL 설정

Netlify로 돌아가서 측면 패널에서 **HTTPS**를 누릅니다. 그리고 DNS가 전파되기를 기다립니다.

![DNS 전파 대기 화면](/assets/part2/waiting-on-dns-propagation.png)

완료되면 Netlify는 Let's Encrypt를 사용하여 SSL 인증서를 자동으로 제공합니다.

![Let's Encrypt 인증서 프로비저닝](/assets/part2/provisioning-lets-encrypt-certificate.png)

인증서가 프로비저닝되기까지 몇 초 기다립니다.

![SSL 인증서 프로비저닝 화면](/assets/part2/ssl-certificate-provisioned.png)

이제 브라우저로 가서 사용자 정의 도메인으로 이동하면 노트 앱이 실행되어 있어야합니다.

![사용자 정의 도메인의 노트 앱](/assets/part2/notes-app-on-custom-domain.png)

운영에 애플리케이션을 가지고 있지만 아직 워크 플로우를 통해 처리할 수는 없습니다. 다음에서 살펴 보겠습니다.
