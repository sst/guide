---
layout: post
title: Deploy Updates
date: 2017-02-12 00:00:00
lang: ko 
description: AWS S3 및 CloudFront에서 호스팅되는 React.js 단일 페이지 응용 프로그램에 업데이트를 배포하는 방법에 대한 자습서입니다. 
comments_id: deploy-updates/16
ref: deploy-updates
---

이제 앱을 어떻게 변경하고 업데이트하는지 살펴 보겠습니다. 이 과정은 S3에 코드를 배치하는 방법과 비슷하지만 몇 가지 변경 사항이 있습니다. 여기에 그 방법을 정리해봅니다.

1. 변경 사항을 적용하여 앱 만들기
2. 기본 S3 버킷에 배포
3. 두 CloudFront 배포판의 캐시 무효화

CloudFront가 객체를 엣지 로케이션에 캐시한 이후에 마지막 단계를 수행해야 합니다. 따라서 사용자가 최신 버전을 볼 수 있게 하려면 CloudFront에 엣지 로케이션의 캐시를 무효화하도록 지정해야합니다.

먼저 앱을 몇 가지 변경하고 배포 프로세스를 진행해 보겠습니다.
