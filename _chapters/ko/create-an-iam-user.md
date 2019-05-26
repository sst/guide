---
layout: post
title: Create an IAM User
date: 2016-12-25 12:00:00
lang: ko
ref: create-an-iam-user
description: 일부 명령 행 도구를 사용하여 AWS와 상호 작용하려면 AWS 콘솔을 통해 IAM 사용자를 작성해야합니다.
context: true
comments_id: create-an-iam-user/92
---

Amazon IAM (Identity and Access Management)을 사용하면 AWS에서 사용자 및 사용자 권한을 관리할 수 있습니다. AWS 계정에 하나 이상의 IAM 사용자를 만들 수 있습니다. AWS 콘솔에 대한 액세스가 필요한 사용자 또는 AWS에 API를 호출해야하는 새 애플리케이션이 있는 경우 IAM 사용자를 만들 수 있습니다. 이것은 AWS 계정에 보안 계층을 추가하는 것입니다.
	
이 장에서는 나중에 사용할 AWS 관련 도구에 대한 새로운 IAM 사용자를 만들 계획입니다.

### 사용자 생성

먼저, [AWS 콘솔](https://console.aws.amazon.com)에 로그인해서 서비스 목록 중에 IAM을 선택합니다.

![IAM Service 선택 스크린샷](/assets/iam-user/select-iam-service.png)

**사용자**를 선택합니다.

![IAM 사용자 스크린샷](/assets/iam-user/select-iam-users.png)

**사용자 추가**를 선택합니다.

![IAM 사용자 추가 스크린샷](/assets/iam-user/add-iam-user.png)

**사용자 이름**을 입력하고 **프로그래밍 방식 액세스**를 선택, 그리고 나서 **다음:권한**을 클릭합니다.

이 계정은 [AWS CLI](https://aws.amazon.com/cli/) 와 [Serverless Framework](https://serverless.com)에서 사용할 예정입니다. 모두 AWS API와 직접 연결하기 위해 사용되며 관리 콘솔을 이용하기 위해 사용되지는 않을 것입니다.

![IAM 사용자 정보 입력하기 스크린샷](/assets/iam-user/fill-in-iam-user-info.png)

**기존 정책 직접 연결**을 선택합니다.

![IAM 사용자 정책 추가하기 스크린샷](/assets/iam-user/add-iam-user-policy.png)


**AdministratorAccess**를 검색해서 정책을 선택한 후, **다음: 태그**를 누르고 **다음: 검토**를 클릭합니다.

나중에 [Serverless IAM 정책 사용자화]({% link _chapters/customize-the-serverless-iam-policy.md %})에서 보다 세부적인 정책을 적용하는 법을 알아보기로 하고 지금은 이 정책설정으로 계속하겠습니다.

![Admin 정책이 추가된 스크린샷](/assets/iam-user/added-admin-policy.png)

**사용자 만들기**를 클릭합니다.

![IAM 사용자 검토 스크린샷](/assets/iam-user/review-iam-user.png)

**표시**를 선택하면 **비밀 액세스 키**를 볼 수 있습니다.

![IAM 사용자 추가된 스크린샷](/assets/iam-user/added-iam-user.png)


**액세스 키 ID** 와 **비밀 액세스 키**는 나중에 사용해야 하므로 따로 적어둡니다.

![IAM 사용자 자격증명 스크린샷](/assets/iam-user/iam-user-credentials.png)

IAM에 대한 개념은 AWS 서비스로 작업 할 때 자주 접할 수 있습니다. 따라서 IAM이 무엇이고 서버리스 보안에 어떻게 도움이 되는지 보다 자세히 살펴볼 필요가 있습니다.

