---
layout: post
title: Automating React Deployments
date: 2018-03-25 00:00:00
lang: ko
description: Git 저장소에 변경 사항을 적용할 때 Create React App을 자동으로 배포하려고 합니다. 이를 위해 Netlify에서 프로젝트를 설정해야합니다. 
context: true
comments_id: automating-react-deployments/188
ref: automating-react-deployments
---

이 가이드의 첫 번째 부분을 따라해 본다면 S3에 Create React App을 배포하고 CloudFront를 CDN으로 사용한다는 사실을 알 수 있습니다. 그런 다음 Route 53을 사용하여 도메인을 구성했습니다. 우리는 또한 도메인의 www 버전을 구성했으며 다른 S3 및 CloudFront 배포가 필요했습니다. 이 과정은 다소 번거로울 수 있습니다.

다음 챕터들에서 우리는 배포를 자동화하기 위해 [Netlify](https://www.netlify.com)라는 서비스를 사용하려고합니다. Serverless 백앤드 API와 조금 비슷합니다. Git에 변경 사항을 적용할 때 React 앱을 배포할 수 있도록 구성합니다. 그러나 백엔드 및 프론트엔드 배포를 구성하는 방식에는 몇 가지 미묘한 차이점이 있습니다.

1. Netlify는 인프라에서 React 앱을 호스팅합니다. 서버리스 백엔드 API의 경우 AWS 계정에서 호스팅합니다.

2. `master` 브랜치로 푸시 된 변경 사항은 React 앱의 운영 버전을 업데이트합니다. 즉, 백엔드와는 약간 다른 과정들을 사용해야합니다. 대부분의 개발 작업을 수행할 별도의 브랜치를 사용할 것이고 일단 운영을 업데이트할 준비가되면 마스터에 푸시하기만 하면됩니다.

백엔드와 마찬가지로 [Travis CI](https://travis-ci.org) 또는 [Circle CI](https://circleci.com)를 사용할 수도 있지만 설정이 조금 더 많습니다. 이에 대해서는 다른 장에서 설명하겠습니다.

