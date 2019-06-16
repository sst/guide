---
layout: post
title: Deploy the Frontend
date: 2017-02-05 00:00:00
lang: ko
description: AWS S3 및 CloudFront에서 React.js 단일 페이지 응용 프로그램을 호스팅하는 방법에 대한 자습서.
comments_id: deploy-the-frontend/39
ref: deploy-the-frontend
---

이제 로컬 환경에서 설정 작업을 완료 했으므로 첫 번째 배포를 수행하고 Serverless 응용 프로그램을 호스팅하기 위해 수행해야 할 작업들을 살펴 보겠습니다.

우리가 사용하게 될 기본 설정은 다음과 같습니다 :

1. 앱의 저작물 업로드합니다.
2. CDN을 사용하여 컨텐츠를 제공합니다.
3. 도메인을 CDN 배포 지점으로 지정합니다.
4. SSL 인증서를 HTTPS로 전환합니다.

AWS는 위 작업들을 수행하는데 도움이 되는 많은 서비스를 제공합니다. [S3](https://aws.amazon.com/s3/)를 사용하여 컨텐츠를 호스팅하고 [CloudFront](https://aws.amazon.com/cloudfront/)를 사용하여 서비스를 제공하며, [Route 53](https://aws.amazon.com/route53/)을 사용하여 도메인을 관리하고 SSL 인증서 처리를 위해 [인증서 관리자](https://aws.amazon.com/certificate-manager/)를 참조합니다.

먼저 S3 버킷을 구성하여 앱의 자산을 업로드하는 것으로 시작해 보겠습니다.
