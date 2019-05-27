---
layout: post
title: Create an S3 Bucket for File Uploads
date: 2016-12-27 00:00:00
lang: ko 
ref: create-an-s3-bucket-for-file-uploads
description: 사용자가 serverless 앱에 파일을 업로드 할 수 있도록 Amazon S3 (Simple Storage Service)를 사용합니다. S3를 사용하면 파일을 저장하고 버킷으로 구성 할 수 있습니다. S3 버킷을 만들고 CORS (Cross-Origin Resource Sharing)를 활성화하여 React.js 앱이 파일을 업로드 할 수 있도록 할 예정입니다.
context: true
comments_id: create-an-s3-bucket-for-file-uploads/150
---


이제 데이터베이스 테이블을 준비했습니다. 파일 업로드를 처리하도록 설정해 보겠습니다. 각 노트는 업로드된 파일을 첨부 파일로 가질 수 있기 때문에 파일 업로드를 처리할 수 있습니다.

[Amazon S3](https://aws.amazon.com/s3/) (Simple Storage Service)는 REST와 같은 웹 서비스 인터페이스를 통해 저장 서비스를 제공합니다. 이미지, 비디오, 파일 등을 포함하여 모든 객체를 S3에 저장할 수 있습니다. 객체는 버킷으로 구성되며 고유한 사용자 지정 키로 각 버킷 내에서 식별됩니다. 

이 장에서는 S3 노트 버킷을 생성하여 노트 앱에서 업로드한 사용자 파일을 저장합니다.

### Bucket 생성하기


먼저 [AWS Console](https://console.aws.amazon.com)에 로그인하고 서비스 목록에서 **S3**를 선택합니다.

![S3 서비스 선택 스크린샷](/assets/s3/select-s3-service.png)

**버킷 만들기**를 클릭합니다.

![버킷 만들기 클릭 스크린샷](/assets/s3/select-create-bucket.png)

버킷의 이름을 입력하고 지역을 선택하십시오. 그런 다음 **생성**을 클릭합니다.

- **버킷 이름**은 전 세계적으로 고유해야 하므로 이 자습서와 동일한 이름을 선택할 수 없습니다.
- **리전**은 파일이 저장된 실제 지리적 영역입니다. 이 가이드는 **미국 동부(버지니아 북부)**를 이용합니다. 

버킷 이름과 리전을 적어 두십시오. 나중에 안내에서 사용하게 될 것입니다.
Make a note of the name and region as we'll be using it later in the guide.

![S3 버킷 정보 스크린샷](/assets/s3/enter-s3-bucket-info.png)

**다음**을 클릭한 이후 모두 기본 설정으로 남겨놓고 다음 단계를 차례로 수행합니다. 그리고 마지막 단계에서 **버킷 만들기**를 클릭합니다.

![S3 버킷 속성 설정 스크린샷](/assets/s3/set-s3-bucket-properties.png)
![S3 버킷 권한 설정 스크린샷](/assets/s3/set-s3-bucket-permissions.png)
![S3 버킷 검토하기 스크린샷](/assets/s3/review-s3-bucket.png)

### CORS 활성화하기

우리가 제작할 노트 앱에서 방금 만든 버킷에 파일을 업로드합니다. 그리고 앱은 커스텀 도메인을 통해 제공 될 것이기 때문에 업로드를 하는 동안 도메인간에 의사 소통을 할 것입니다. 기본적으로 S3는 다른 도메인에서 리소스에 액세스하는 것을 허용하지 않습니다. 그러나 CORS(Cross-Origin Resource Sharing)는 한 도메인에 로드된 클라이언트 웹 응용 프로그램이 다른 도메인의 리소스와 상호 작용할 수 있는 방법을 정의합니다. S3 버킷에 CORS를 사용하도록 설정합니다.

방금 생성한 버컷을 선택합니다.

![S3 생성한 버컷 선택 스크린샷](/assets/s3/select-created-s3-bucket.png)

**권한** 탭을 선택합니다. 그리고 **CORS 구성**을 클릭합니다.

![S3 버킷의 CORS 구성을 선택하는 스크린샷](/assets/s3/select-s3-bucket-cors-configuration.png)

CORS 구성 편집기에 아래 내용을 추가하고 **저장** 버튼을 클릭합니다.

``` xml
<CORSConfiguration>
	<CORSRule>
		<AllowedOrigin>*</AllowedOrigin>
		<AllowedMethod>GET</AllowedMethod>
		<AllowedMethod>PUT</AllowedMethod>
		<AllowedMethod>POST</AllowedMethod>
		<AllowedMethod>HEAD</AllowedMethod>
		<AllowedMethod>DELETE</AllowedMethod>
		<MaxAgeSeconds>3000</MaxAgeSeconds>
		<AllowedHeader>*</AllowedHeader>
	</CORSRule>
</CORSConfiguration>
```
운영 환경에서 사용할 때에는 여러분의 도메인이나 도메인 목록을 사용해서 구성할 수 있습니다.

![S3 버킷의 CORS 구성을 저장하는 스크린샷](/assets/s3/save-s3-bucket-cors-configuration.png)

이제 S3 버킷이 준비되었습니다. 사용자 인증을 처리하도록 설정해 보겠습니다.

