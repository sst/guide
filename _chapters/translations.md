---
layout: post
title: Translations
date: 2018-03-30 12:00:00
comments_id: comments-translations/788
---

Our guide is available in several languages thanks to contributions by our incredible readers. You can view the translated versions of a chapter by clicking on the links below the chapter title.

![Chapter translation links Screenshot](/assets/chapter-translation-links.png)

Below is a list of all the chapters that are available in multiple languages. If you are interested in helping with our translation efforts, leave us a [comment here](https://discourse.serverless-stack.com/t/help-us-translate-serverless-stack/596/15).  

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

A big thanks to our contributors for helping make Serverless Stack more accessible!

- [Bernardo Bugmann](https://github.com/bernardobugmann)
- [Sebastian Gutierrez](https://github.com/pepas24)
- [Vincent Oliveira](https://github.com/vincentoliveira)
- [Leonardo Gonzalez](https://github.com/leogonzalez)
- [Vieko Franetovic](https://github.com/vieko)
- [Christian Kaindl](https://github.com/christiankaindl)
