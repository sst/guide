---
layout: lander
description: "Serverless Stack (SST) is a framework that makes it easy to build serverless applications. Check out our examples to get started. Or follow our step-by-step tutorials for creating full-stack apps with serverless and React.js on AWS. Build a serverless REST API with our Serverless tutorial and connect it to a React single-page application with our React.js tutorial."
---

<div id="table-of-contents" class="table-of-contents">

  <div class="wrapper">

    <div class="col1">
      <div class="part">
        <div id="the-basics" class="header">
          <h3>The Basics</h3>
          <p>Build your first Serverless app using AWS Lambda and React.</p>
        </div>
        <div class="chapters the-basics">
          {% include toc-chapters.html items=site.data.chapterlist.preface id="preface" %}

          {% include toc-chapters.html items=site.data.chapterlist.intro id="intro" %}

          {% include toc-chapters.html items=site.data.chapterlist.setup-aws id="setup-aws" %}
          {% include toc-chapters.html items=site.data.chapterlist.setup-serverless id="setup-serverless" %}
          {% include toc-chapters.html items=site.data.chapterlist.setup-backend id="setup-backend" %}
          {% include toc-chapters.html items=site.data.chapterlist.build-api id="build-api" %}
          {% include toc-chapters.html items=site.data.chapterlist.users-auth id="users-auth" %}
          {% include toc-chapters.html items=site.data.chapterlist.third-party-apis id="third-party-apis" %}
          {% include toc-chapters.html items=site.data.chapterlist.unit-tests id="unit-tests" %}
          {% include toc-chapters.html items=site.data.chapterlist.cors id="cors" %}

          {% include toc-chapters.html items=site.data.chapterlist.setup-react id="setup-react" %}
          {% include toc-chapters.html items=site.data.chapterlist.react-routes id="react-routes" %}
          {% include toc-chapters.html items=site.data.chapterlist.setup-amplify id="setup-amplify" %}
          {% include toc-chapters.html items=site.data.chapterlist.build-react id="build-react" %}
          {% include toc-chapters.html items=site.data.chapterlist.secure-pages id="secure-pages" %}
          {% include toc-chapters.html items=site.data.chapterlist.domains-hosting id="domains-hosting" %}

          {% include toc-chapters.html items=site.data.chapterlist.infrastructure-as-code id="infrastructure-as-code" %}
          {% include toc-chapters.html items=site.data.chapterlist.automating-deployments id="automating-deployments" %}

          {% include toc-chapters.html items=site.data.chapterlist.monitor-debug-errors id="monitor-debug-errors" %}
          {% include toc-chapters.html items=site.data.chapterlist.conclusion id="conclusion" %}
          <a class="expand"><span>Show all chapters</span></a>
        </div>
      </div>
    </div>

    <div class="col2">
      <div class="part">
        <div id="best-practices" class="header best-practices">
          <h3>Best Practices</h3>
          <p>The best practices for running Serverless apps in production.</p>
        </div>
        <div class="chapters best-practices">
          {% include toc-chapters.html items=site.data.chapterlist.best-practices-intro id="best-practices-intro" %}
          {% include toc-chapters.html items=site.data.chapterlist.organize-serverless-apps id="organize-serverless-apps" %}
          {% include toc-chapters.html items=site.data.chapterlist.configure-environments id="configure-environments" %}
          {% include toc-chapters.html items=site.data.chapterlist.development-lifecycle id="development-lifecycle" %}
          {% include toc-chapters.html items=site.data.chapterlist.observability id="observability" %}
          {% include toc-chapters.html items=site.data.chapterlist.best-practices-conclusion id="best-practices-conclusion" %}
          <a class="expand"><span>Show all chapters</span></a>
        </div>
      </div>

      <div class="part">
        <div id="extra-credit" class="header extra-credit">
          <h3>Extra Credit</h3>
          <p>Standalone chapters on specific topics for reference.</p>
        </div>
        <div class="chapters">
          {% include toc-chapters.html items=site.data.chapterlist.extra-backend id="extra-backend" %}
          {% include toc-chapters.html items=site.data.chapterlist.extra-auth id="extra-auth" %}
          {% include toc-chapters.html items=site.data.chapterlist.extra-frontend id="extra-frontend" %}
          <a class="expand"><span>Show all chapters</span></a>
        </div>
      </div>
    </div>
  </div>

</div>
