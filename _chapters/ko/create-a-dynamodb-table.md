---
layout: post
title: Create a DynamoDB Table
date: 2016-12-27 00:00:00
lang: ko
ref: create-a-dynamodb-table
description: Amazon DynamoDB는 완벽하게 관리되는 NoSQL 데이터베이스로 서버리스 API 백엔드에 동력을 공급합니다. DynamoDB는 테이블에 데이터를 저장하고 각 테이블에는 설정된 후에는 변경할 수없는 기본 키가 있습니다. 또한 DynamoDB 테이블에 대한 읽기 및 쓰기 설정을 통해 처리량 용량을 프로비저닝 할 예정입니다.
context: true
comments_id: create-a-dynamodb-table/139
---

노트 앱의 백앤드를 구축하려면 제일 먼저 데이터 저장 방법을 고려하는 것이 좋습니다. 여기에서는 [DynamoDB](https://aws.amazon.com/dynamodb/)를 사용하여 이 작업을 수행할 것입니다.

### DynamoDB에 관하여

Amazon DynamoDB는 완벽하게 관리되는 NoSQL 데이터베이스로 완벽한 확장성으로 빠르고 예측 가능한 성능을 제공합니다. 다른 데이터베이스와 마찬가지로 DynamoDB는 테이블에 데이터를 저장합니다. 각 테이블은 여러 항목을 포함하여 하나 이상이 속성으로 구성됩니다. 다음 장에서 몇 가지 기본 사항을 다룰 예정입니다. 그러나 더 자세한 정보를 얻으려면 여기 [훌륭한 DynamoDB 안내서](https://www.dynamodbguide.com)가 있습니다.

### Table 생성하기

먼저 [AWS Console](https://console.aws.amazon.com)에 로그인하고 서비스 목록에서 **DynamoDB**를 선택합니다.

![DynamoDB 서비스 선택 screenshot](/assets/dynamodb/select-dynamodb-service.png)

**테이블 만들기** 선택.

![DynamoDB Table 생성 screenshot](/assets/dynamodb/create-dynamodb-table.png)

**테이블 이름**을 입력하고 **기본 키**에 아래 정보와 같이 `userId` 와 `noteId`를 카멜 케이스 방식으로 입력합니다.

![테이블 기본키 생성 screenshot](/assets/dynamodb/set-table-primary-key.png)

각 DynamoDB 테이블에는 기본 키가 있으며이 키는 한 번 설정하면 변경할 수 없습니다. 기본 키는 테이블의 각 항목을 고유하게 식별하므로 두 항목이 동일한 키를 가질 수 없습니다. DynamoDB는 두 가지 다른 종류의 기본 키를 지원합니다:

* 파티션 키
* 파티션 키와 정렬 키 (복합)

우리는 데이터를 질의 할 때 추가적인 유연성을 제공하는 복합 기본 키를 사용할 것입니다. 예를 들어, `userId`에 대한 값만 제공하면 DynamoDB는 해당 사용자가 모든 노트를 검색합니다. 또는 특정 노트를 검색하기 위해`userId`에 대한 값과`noteId`에 대한 값을 함께 지정 할 수 있습니다.

DynamoDB에서 인덱스가 작동하는 방식에 대한 이해를 돕기 위해 [DynamoDB 핵심 컴포넌트][dynamodb-components]를 추가로 살펴 볼 수 있습니다.

다음 메시지가 표시되는 화면에서 **기본 설정 사용**을 선택 취소하십시오.

![자동 스케일링 IAM 역할 경고 스크린샷](/assets/dynamodb/auto-scaling-iam-role-warning.png)

맨 아래로 스크롤하여 **DynamoDB AutoScaling Service Linked Role**이 선택되었는지 확인하고 **생성**을 선택하십시오.

![프로비저닝 된 용량 테이블 설정 스크린샷](/assets/dynamodb/set-table-provisioned-capacity.png)

그렇지 않으면 **기본 설정 사용**이 선택되어 있는지 확인한 다음 **생성**을 선택합니다.

기본 설정은 5개의 읽기와 5개의 쓰기를 제공합니다. 테이블을 작성할 때 읽기와 쓰기에 예약할 처리 용량을 지정합니다. DynamoDB는 처리 요구량을 충족시키는 데 필요한 리소스를 예약하는 동시에 일관성 있고 짧은 지연 시간에 대한 성능을 보장합니다. 하나의 읽기 용량 단위는 초당 최대 8KB를 읽을 수 있으며 하나의 쓰기 용량 단위는 초당 최대 1KB를 쓸 수 있습니다. 프로비저닝된 처리량 설정을 변경하여 필요에 따라 용량을 늘리거나 줄일 수 있습니다.

`notes` 테이블이 생성되었습니다. **테이블을 작성 중입니다.** 메시지가 표시되면서 아무런 변화가 없다면 페이지를 수동으로 새로 고침하십시오.

![DynamoDB 서비스 선택 스크린샷](/assets/dynamodb/dynamodb-table-created.png)

DynamoDB 테이블에 대한 백업을 설정하는 것이 좋습니다. 특히 운영 환경에서 사용하는 경우에는 말이죠. 백업에 관해서는 별도 크래딧 챕터에서 다룹니다. [DynamoDB에서의 백업]({% link _chapters/backups-in-dynamodb.md %}).

다음으로 파일 업로드를 처리할 수 있는 S3 버킷을 설정합니다.

[dynamodb-components]: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
