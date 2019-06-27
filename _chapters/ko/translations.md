---
layout: post
title: 번역 
date: 2018-03-30 12:00:00
lang: ko
comments_id: comments-translations/788
ref: translations
---

저희 가이드는 소중한 독자들의 도움으로 다양한 언어로 제공됩니다. 챕터 제목 아래에 있는 링크를 클릭하여 챕터의 번역된 버전을 볼 수 있습니다.

![챕터 번역 링크 화면](/assets/chapter-translation-links.png)

다음은 여러 언어로 제공되는 모든 챕터들의 목록입니다. 번역 작업에 관심이 있으시면 [여기](https://discourse.serverless-stack.com/t/help-us-translate-serverless-stack/596/15)에 의견을 남겨 주십시오.

---

<div>
  {% for page in site.chapters %}
    {% if page.lang == "en" and page.ref %}
      {% assign pages = site.chapters | where:"ref", page.ref | where_exp:"page", "page.lang != 'en'" | sort: 'lang' %}
      {% if pages.size > 0 %}
        <a href="{{ page.url }}">{{ page.title }}</a>
        <ul>
        {% for page in pages %}
          <li>{{ page.lang }}: <a href="{{ page.url }}">{{ page.title }}</a></li>
        {% endfor %}
        </ul>
      {% endif %}
    {% endif %}
  {% endfor %}
</div>

---

Serverless Stack을 보다 쉽게 사용할 수 있도록 공헌해주신  여러분께 진심으로 큰 감사를 드립니다!

- [Bernardo Bugmann](https://github.com/bernardobugmann)
- [Sebastian Gutierrez](https://github.com/pepas24)
- [Vincent Oliveira](https://github.com/vincentoliveira)
- [Leonardo Gonzalez](https://github.com/leogonzalez)
- [Vieko Franetovic](https://github.com/vieko)
- [Christian Kaindl](https://github.com/christiankaindl)
