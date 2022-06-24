---
layout: post
ref: what-does-this-guide-cover
title: What Does This Guide Cover?
date: 2016-12-22 00:00:00
lang: ko 
ref: what-does-this-guide-cover
context: true
comments_id: what-does-this-guide-cover/83
---

웹 애플리케이션 구축과 관련된 주요 개념을 단계별로 수행하기 위해 [**스크래치**](https://demo2.sst.dev)라는 간단한 노트 작성 응용 프로그램을 제작하려고합니다.

![완성된 데스크탑 앱 화면](/assets/completed-app-desktop.png)

<img alt="완성된 앱 모바일 화면" src="/assets/completed-app-mobile.png" width="432" />

JavaScript로 작성된 서버리스 API로 구동되는 단일 페이지 응용프로그램입니다. [백앤드]({{site.backend_github_repo}}) 및 [프론트앤드]({{site.frontend_github_repo}})의 전체 소스는 다음과 같습니다. 비교적 간단한 응용 프로그램이지만 다음 요구 사항을 처리 할 것입니다.

- 사용자가 가입하고 계정에 로그인 할 수 있어야합니다.
- 사용자는 일부 콘텐츠가 포함 된 메모를 만들 수 있어야합니다.
- 각 메모에는 첨부 파일로 업로드 된 파일이 있을 수도 있습니다.
- 사용자가 메모 및 첨부 파일을 수정할 수 있습니다.
- 사용자는 메모를 삭제할 수 있습니다.
- 앱에서 신용 카드 결제를 처리할 수 있어야합니다.
- 사용자 도메인에서 HTTPS를 통해 앱을 서비스해야합니다.
- 백엔드 API는 안전해야합니다.
- 앱이 반응적이어야합니다.

우리는 AWS Platform을 사용하여 이를 구축 할 것입니다. 물론 더 확장 가능한 몇 가지 다른 플랫폼들을 다룰수도 있지만 AWS 플랫폼이 시작하기에 좋은 곳이라고 생각했습니다.

### 기술과 서비스

다음과 같은 일련의 기술과 서비스를 사용하여 서버리스 애플리케이션을 구축할 것입니다.

- [Lambda][Lambda] & [API Gateway][APIG] 서버리스 API 구현
- [DynamoDB][DynamoDB] 데이터베이스
- [Cognito][Cognito] 사용자 인증과 API 보안
- [S3][S3] 앱과 파일 업로드 호스팅
- [CloudFront][CF] 앱 서비스
- [Route 53][R53] 도메인 서비스
- [Certificate Manager][CM] SSL 적용
- [React.js][React] 단일 페이지 앱
- [React Router][RR] 라우팅 서비스 
- [Bootstrap][Bootstrap] UI Kit
- [Stripe][Stripe] 신용카드 결제 처리 
- [Seed][Seed] 서버리스 배포 자동화
- [Netlify][Netlify] React 배포 자동화
- [GitHub][GitHub] 프로젝트 저장소

우리는 위 서비스에 대해 **무료 티어**를 사용하려고합니다. 따라서 무료로 가입할 수 있어야합니다. 이것은 물론 앱을 호스팅할 새 도메인을 구입하는 경우에는 적용되지 않습니다. 또한 AWS의 경우 계정을 만드는 동안 신용 카드를 사용해야합니다. 따라서 자습서에서 다루는 것 이상으로 리소스를 생성하는 경우 부득이 요금이 청구될 수도 있습니다.

위 목록은 다소 어려울 수도 있지만 가이드를 완료하고 나면 **실제로** **안전하고**  **완벽한 기능을 지닌** 웹 앱을 만들 준비가 완료됩니다. 그리고 걱정하지 마십시오 우리가 도와드리겠습니다!

### 필요사항 

여러분은 [Node v8.10+ and NPM v5.5+](https://nodejs.org/en/)가 필요합니다. 또한 명령 행을 사용하는 방법에 대한 기본 지식이 필요합니다.

### 이 안내서의 구조 

가이드는 두 부분으로 나뉩니다. 둘 다 상대적으로 독립적입니다. 첫 번째 부분은 기본 사항을 다루지 만 두 번째 항목은 설정을 자동화하는 방법과 함께 몇 가지 고급 주제를 다룹니다. 우리는 2017년 초반에이 안내서를 시작했습니다. SST 커뮤니티가 성장했으며 많은 독자들이 이 가이드에서 설명한 설정을 사용하여 비즈니스를 강화하는 앱을 개발했습니다.

그래서 우리는 가이드를 확장하고 두 번째 파트를 추가하기로 결정했습니다. 이 프로젝트는 이 설정을 사용하려는 사람들을 대상으로합니다. 파트 I의 모든 수동 단계를 자동화하고 상용 서비스를 포함해서 모든 서버리스 프로젝트에 바로 사용할 수있는 워크 플로우를 작성하는데 도움을줍니다. 다음은 두 부분에서 다루는 내용입니다.

#### 파트 I

노트 응용 프로그램을 만들고 배포합니다. 우리는 모든 기본적인 내용을 다룹니다. 각 서비스는 손으로 작성됩니다. 여기에 순서대로 적용되는 내용이 있습니다.

백엔드의 경우 :

- AWS 계정 구성
- DynamoDB를 사용하여 데이터베이스 만들기
- 파일 업로드를 위해 S3 설정
- 사용자 계정을 관리 할 Cognito 사용자 풀 설정
- 파일 업로드를 보호하기 위해 Cognito Identity 풀 설정
- Serverless Framework를 Lambda 및 API 게이트웨이와 함께 사용하도록 설정
- 다양한 백엔드 API 작성

프론트 엔드의 경우 :

- Create React App으로 프로젝트 설정
- 부트 스트랩을 사용하여 파비콘, 글꼴 및 UI 키트 추가
- React-Router를 사용하여 경로 설정
- AWS Cognito SDK를 사용하여 사용자 로그인 및 가입
- 노트를 관리하기위한 백엔드 API에 대한 플러그인
- AWS JS SDK를 사용하여 파일 업로드
- S3 버킷을 만들어 앱 업로드
- CloudFront가 앱을 제공하도록 구성
- Route 53에서 CloudFront 로의 사용자 도메인 지정
- HTTPS를 통해 앱을 제공하도록 SSL을 설정합니다.

#### 파트 II

일상적인 프로젝트에 SST을 사용하려는 사람들을 대상으로합니다. 우리는 첫 번째 부분부터 모든 단계를 자동화합니다. 여기에 순서대로 적용되는 내용이 있습니다.

백엔드의 경우 :

- 코드를 통해 DynamoDB 구성
- 코드를 통해 S3 구성
- 코드를 통해 Cognito 사용자 풀 구성
- 코드를 통해 Cognito Identity 풀 구성
- Serverless Framework의 환경 변수
- Stripe API로 작업하기
- Serverless Framework의 비밀 작업
- Serverless의 단위 테스트
- 시드를 사용하여 배포 자동화
- 시드를 통해 맞춤 도메인 구성
- 시드를 통한 배포 모니터링

프론트 엔드 용

- Create React App의 환경
- React에서 신용 카드 결제 허용
- Netlify를 사용하여 배포 자동화
- Netlify를 통해 맞춤 도메인 구성

우리는 이러한 내용들이 바로 서비스 가능한 풀스택의 준비된 서버리스 애플리케이션 구축에 좋은 토대가 될 것이라고 생각합니다. 우리가 다루고 싶은 다른 개념이나 기술이 있다면 [포럼]({{site.forum_url}})에서 알려주십시오.

[Cognito]: https://aws.amazon.com/cognito/
[CM]: https://aws.amazon.com/certificate-manager
[R53]: https://aws.amazon.com/route53/
[CF]: https://aws.amazon.com/cloudfront/
[S3]: https://aws.amazon.com/s3/
[Bootstrap]: http://getbootstrap.com
[RR]: https://github.com/ReactTraining/react-router
[React]: https://facebook.github.io/react/
[DynamoDB]: https://aws.amazon.com/dynamodb/
[APIG]: https://aws.amazon.com/api-gateway/
[Lambda]: https://aws.amazon.com/lambda/
[Stripe]: https://stripe.com
[Seed]: https://seed.run
[Netlify]: https://netlify.com
[GitHub]: https://github.com
