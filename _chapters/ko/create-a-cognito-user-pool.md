---
layout: post
title: Create a Cognito User Pool
date: 2016-12-28 00:00:00
description: Amazon Cognito User Pool은 웹 및 모바일 앱용 가입 및 로그인 기능을 처리합니다. 우리는 서버리스 앱을위한 사용자를 저장하고 관리하기 위해 Cognito User Pool을 만들 예정입니다. 우리는 사용자가 이메일로 로그인하기를 원하기 때문에 이메일 주소를 사용자 이름 옵션으로 사용합니다. 또한 Cognito 사용자 풀의 앱 클라이언트로 앱을 설정할 예정입니다.
lang: ko
ref: create-a-cognito-user-pool
context: true
comments_id: create-a-cognito-user-pool/148
---

우리 노트 애플 리케이션은 안전하고 신뢰할 수있는 방법으로 사용자 계정과 인증을 처리해야합니다. 이를 위해 우리는 [Amazon Cognito](https://aws.amazon.com/cognito/)를 사용하려고 합니다.

Amazon Cognito User Pool을 사용하면 개발자가 웹 및 모바일 애플리케이션에 등록 및 로그인 기능을 쉽게 추가 할 수 있습니다. 사용자 디렉토리를 유지 관리하는 고유 한 ID 제공 업체 역할을합니다. 사용자 로그인 및 로그인을 지원하고 로그인 한 사용자의 인증 토큰을 프로비저닝합니다.

이 장에서는 노트 앱용 사용자 풀을 생성합니다.

### 사용자 풀 만들기

여러분의 [AWS 콘솔](https://console.aws.amazon.com)에서, 서비스 목록에서 **Cognito**를 선택합니다.

![Amazon Cognito 서비스 선택 스크린샷](/assets/cognito-user-pool/select-cognito-service.png)

**사용자 풀 관리**를 클릭합니다.

![사용자 풀 관리 선택 스크린샷](/assets/cognito-user-pool/select-manage-your-user-pools.png)

**사용자 풀 생성**을 클릭합니다.

![사용자 풀 생성 선택 화면](/assets/cognito-user-pool/select-create-a-user-pool.png)

**풀 이름**을 입력하고 **기본값 검토**를 클릭합니다.

![사용자 풀 입력 화면](/assets/cognito-user-pool/fill-in-user-pool-info.png)

**사용자 이름 속성 선택**을 클릭합니다.

![사용자 이름 속성 선택 화면](/assets/cognito-user-pool/choose-username-attributes.png)

**이메일 주소 또는 전화 번호**를 선택하고 **이메일 주소 허용**을 선택합니다. 이것은 사용자들에게 그들의 회워가입시 로그인 사용자 이름으로 자신의 이메일을 사용할 수 있도록 Cognito 사용자 풀에 지정하는 것입니다.

![사용자 이름으로 이메일 선택 화면](/assets/cognito-user-pool/select-email-address-as-username.png)

**다은 단계**를 선택하고 아래로 스크롤합니다.

![다음 단계 선택화면](/assets/cognito-user-pool/select-next-step-attributes.png)

화면 왼쪽 패널에 **검토** 메뉴를 클릭하고 **사용자 이름 속성**에 **email**이 정확히 설정되어 있는지 확인합니다.

![사용자 풀 설정 검토 화면](/assets/cognito-user-pool/review-user-pool-settings.png)

이제 화면 아래에 **풀 생성**을 클릭합니다.

![풀 생성 클릭 화면](/assets/cognito-user-pool/select-create-pool.png)

여러분의 사용자 풀이 만들어졌습니다. **풀 ID**와 **풀 ARN** 값을 나중에 사용해야하므로 따로 적어 놓습니다. 또한 사용자 풀이 생성된 리전도 적어 놓습니다. - 여기에서는 `us-east-1`로 설정되었습니다.

![Cognito 사용자 풀 생성완료 화면](/assets/cognito-user-pool/user-pool-created.png)

### 앱 클라이언트 만들기

화면 왼쪽 패널에서 **앱 클라이언트**를 선택합니다.

![Congito 사용자 풀 앱 화면](/assets/cognito-user-pool/select-user-pool-apps.png)

**앱 클라이어트 추가**를 선택합니다.

![앱 클라이언트 추가 선택 화면](/assets/cognito-user-pool/select-add-an-app.png)

**앱 클라이언트 이름**을 입력하고 **클라이언트 보안키 생성**을 선택 취소하고 **서버 기반 인증용 로그인 API 활성화**를 선택한 다음 **앱 클라이언트 생성**을 선택하십시오.

- **클라이언트 보안키 생성** : 클라이언트 보안 키를 가진 사용자 풀 앱은 JavaScript SDK에서 지원하지 않습니다. 옵션의 선택을 취소해야합니다.
- **서버 기반 인증용 로그인 API 활성화** : 명령 줄 인터페이스를 통해 풀 사용자를 관리 할 때 AWS CLI에서 필요합니다. 다음 장에서 명령 줄 인터페이스를 통해 테스트 사용자를 생성 할 것입니다.


![Cognito 사용자 풀 앱 정보 입력하는 화면](/assets/cognito-user-pool/fill-user-pool-app-info.png)

이제 여러분의 앱 클라이언트가 만들어졌습니다. **앱 클라이언트 ID**를 다음 장에서 필요하므로 적어 놓습니다.

![Cognito 사용자 풀 앱 생성 화면](/assets/cognito-user-pool/user-pool-app-created.png)


### 도메인 이름 만들기

마지막으로, 화면 왼쪽에서 **도메인 이름**을 클릭합니다. 여러분의 도메인 이름을 입력하고 **변경 내용 저장**을 클릭합니다. 여기에서는 `notes-app`을 사용합니다.(같은 이름을 사용할 경우 AWS 내에서 중복오류가 발생할 수 있으므로 **가용성 확인**을 클릭해서 먼저 확인합니다.)

![Congito 사용자 풀 앱 도메인 이름 생성 화면](/assets/cognito-user-pool/user-pool-domain-name.png)

이제 Cognito 사용자 풀이 준비 되었습니다. 이를 통해 여러분의 노트 앱을 위한 사용자 디렉토리를 유지하면서 API 액세스로 인증하는데도 사용합니다. 다음으로 풀에서 테스트 사용자를 설정해 보겠습니다. 
