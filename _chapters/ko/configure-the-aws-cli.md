---
layout: post
title: Configure the AWS CLI
date: 2016-12-26 00:00:00
lang: ko 
ref: configure-the-aws-cli
description: 명령 줄을 사용하여 AWS와 상호 작용하려면 AWS 명령 행 인터페이스 (또는 AWS CLI)를 설치해야합니다. 또한 AWS 콘솔의 IAM 사용자 액세스 키 ID 및 비밀 액세스 키를 사용하여 구성해야합니다.
context: true
comments_id: configure-the-aws-cli/86
---

AWS의 많은 서비스를 보다 쉽게 사용하기 위해 [AWS CLI](https://aws.amazon.com/cli/)를 사용하겠습니다.

### AWS CLI 인스톨하기

AWS CLI는 Python 2 버전 2.6.5+ 또는 Python 3 버전 3.3+ 와 [Pip](https://pypi.python.org/pypi/pip)가 필요합니다. Python 또는 Pip 설치가 필요하면 아래 링크를 참고하세요.

- [Python 인스톨하기](https://www.python.org/downloads/)
- [Pip 인스톨하기](https://pip.pypa.io/en/stable/installing/)

<img class="code-marker" src="/assets/s.png" />이제 Pip를 실행서 AWS CLI (Linux, macOS, 또는 Unix)를 설치할 수 있습니다:

``` bash
$ sudo pip install awscli
```

또는 macOS를 사용하고 있다면 [Homebrew](https://brew.sh)를 이용합니다:

``` bash
$ brew install awscli
```

만일 AWS CLI 설치하는 데 문제가 있거나 윈도우즈에서 인스톨 지침서가 필요하다면 [최신 사용자 설치 가이드](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)를 참고하세요.

### AWS CLI 사용자 액세스 키 추가하기

이전 장에서 생성한 액세스 키를 사용하도록 AWS CLI에 설정합니다.

해당 정보는 다음과 같습니다:

- 액세스 키 ID **AKIAIOSFODNN7EXAMPLE**
- 보안 액세스 키 **wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY**

<img class="code-marker" src="/assets/s.png" />비밀 키 ID와 액세스 키를 설정하기 위해 다음을 실행하면됩니다.

``` bash
$ aws configure
```

**기본 리전명** 및 **기본 출력 형식**을 그대로 유지할 수 있습니다.

다음으로 백엔드 설정을 시작하겠습니다.
