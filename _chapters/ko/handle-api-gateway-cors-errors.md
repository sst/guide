---
layout: post
title: Handle API Gateway CORS Errors
date: 2017-01-03 12:00:00
description: 4xx 및 5xx 오류를 처리하기 위해 CORS 헤더를 Serverless API Gateway 엔드 포인트에 추가해야합니다. 이것은 우리의 람다 함수가 호출되지 않는 경우를 처리하기위한 것입니다.
lang: ko
ref: handle-api-gateway-cors-errors
context: true
code: backend
comments_id: handle-api-gateway-cors-errors/780
---

API를 배포하기 전에 마지막으로 설정해야합니다. CORS 헤더를 API Gateway 오류에 추가해야합니다. [노트 추가 API 생성하기]({% link _chapters/add-a-create-note-api.md %}) 장에서 우리는 람다 함수에 CORS 헤더를 추가했다는 것을 상기 할 수 있습니다. 그러나 우리가 API 요청을 할 때, API Gateway는 Lambda 함수 전에 호출됩니다. 즉, API Gateway 수준에서 오류가 발생하면 CORS 헤더가 설정되지 않습니다.

따라서 이러한 오류를 디버깅하는 것은 정말 어려울 수 있습니다. 고객이 오류 메시지를 볼 수 없으며 다음과 같이 표시됩니다.

```
No 'Access-Control-Allow-Origin' header is present on the requested resource
```

CORS 관련 오류는 가장 일반적인 Serverless API 오류 중 하나입니다. 이 장에서는 HTTP 오류가있는 경우 CORS 헤더를 설정하도록 API Gateway를 구성하려고합니다. 지금 당장은 이를 테스트 할 수 없지만 프론트 엔드 클라이언트에서 작업 할 때 정말 도움이 될 것입니다.

### 리소스 만들기 

API Gateway 오류를 구성하기 위해 우리는`serverless.yml`에 몇 가지를 추가 할 것입니다. 기본적으로 [Serverless Framework](https://serverless.com)는 [CloudFormation] (https://aws.amazon.com/cloudformation/)을 지원하므로 코드를 통해 API Gateway를 구성 할 수 있습니다.

<img class="code-marker" src="/assets/s.png" />리소스를 추가 할 디렉토리를 만들어 보겠습니다. 나중에이 가이드의 뒷부분에 추가하겠습니다.

``` bash
$ mkdir resources/
```

<img class="code-marker" src="/assets/s.png" />그리고 `resources/api-gateway-errors.yml`에 다음 내용을 추가합니다.

``` yml
Resources:
  GatewayResponseDefault4XX:
    Type: 'AWS::ApiGateway::GatewayResponse'
    Properties:
      ResponseParameters:
         gatewayresponse.header.Access-Control-Allow-Origin: "'*'"
         gatewayresponse.header.Access-Control-Allow-Headers: "'*'"
      ResponseType: DEFAULT_4XX
      RestApiId:
        Ref: 'ApiGatewayRestApi'
  GatewayResponseDefault5XX:
    Type: 'AWS::ApiGateway::GatewayResponse'
    Properties:
      ResponseParameters:
         gatewayresponse.header.Access-Control-Allow-Origin: "'*'"
         gatewayresponse.header.Access-Control-Allow-Headers: "'*'"
      ResponseType: DEFAULT_5XX
      RestApiId:
        Ref: 'ApiGatewayRestApi'
```

위 내용을 보면 약간 위협적으로 보일 수도 있을 것 같습니다. 위 구문은 CloudFormation 리소스를 나타내고 상당히 장황한 경향이 있습니다. 그러나 여기서의 세부 사항은 그다지 중요하지 않습니다. 우리는 우리의 응용 프로그램에서`ApiGatewayRestApi` 자원에 CORS 헤더를 추가하고 있습니다. `GatewayResponseDefault4XX`는 4xx 에러를 위한 것이고,`GatewayResponseDefault5XX`는 5xx 에러를 위한 것입니다.

### 리소스 포함시키기 

이제 위의 CloudFormation 리소스를`serverless.yml`에 포함시켜 보겠습니다.

<img class="code-marker" src="/assets/s.png" />`serverless.yml` 파일에 아래 내용을 추가합니다.

``` yml
# 분리된 CloudFormation 템플릿을 생성합니다. 
resources:
  # API Gateway 에러 
  - ${file(resources/api-gateway-errors.yml)}
```

이제 API를 배포할 준비가 되었습니다.
