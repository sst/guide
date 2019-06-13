---
layout: post
title: Create a Signup Page
date: 2017-01-19 00:00:00
lang: ko
ref: create-a-signup-page
comments_id: create-a-signup-page/65
---

가입 페이지는 방금 만든 로그인 페이지와 매우 유사합니다. 그러나 두 가지 중요한 차이점이 있습니다. 사용자로 가입하면 AWS Cognito가 이메일로 확인 코드를 보냅니다. 신규 사용자가 가입을 확인한 후에는 새 사용자로 인증합니다.

따라서 가입 절차는 다음과 같습니다.

1. 사용자가 이메일, 암호를 입력하고 확인합니다.

2. AWS Amplify 라이브러리를 사용하여 Amazon Cognito에 등록하고 사용자 정보를 얻습니다.

3. 그런 다음 AWS Cognito가 이메일로 보낸 확인 코드를 수락할 양식을 렌더링합니다.

4. AWS Cognito에서 확인 코드를 보내고 등록을 확인합니다.

5. 새로 생성 된 사용자를 인증합니다.

6. 마지막으로 앱 state를 세션으로 업데이트합니다.

먼저 기본 가입 양식을 작성하여 시작하겠습니다.
