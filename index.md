---
layout: lander
description: Free step-by-step tutorials for creating full-stack apps with Serverless Framework and React.js. Build a Serverless REST API with our Serverless tutorial and connect it to a React single-page application with our React.js tutorial. Use our AWS tutorial with screenshots to deploy your full-stack app.
---

<div id="table-of-contents" class="table-of-contents">

  <div class="header"><h6>Table of Contents</h6></div>

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
          {% include toc-chapters.html items=site.data.chapterlist.setup-backend id="setup-backend" %}
          {% include toc-chapters.html items=site.data.chapterlist.build-api id="build-api" %}
          {% include toc-chapters.html items=site.data.chapterlist.deploy-backend id="deploy-backend" %}
          {% include toc-chapters.html items=site.data.chapterlist.setup-react id="setup-react" %}
          {% include toc-chapters.html items=site.data.chapterlist.build-react id="build-react" %}
          {% include toc-chapters.html items=site.data.chapterlist.deploy-backend-prod id="deploy-backend-prod" %}
          {% include toc-chapters.html items=site.data.chapterlist.deploy-frontend-prod id="deploy-frontend-prod" %}
          {% include toc-chapters.html items=site.data.chapterlist.conclusion id="conclusion" %}
          <a class="expand"><span>Show all chapters</span></a>
        </div>
      </div>
    </div>

    <div class="col2">
      <div class="part">
        <div id="best-practices" class="header">
          <h3>Best Practices</h3>
          <p>The best practices for running Serverless apps in production.</p>
        </div>
        <div class="chapters">
          {% include toc-chapters.html items=site.data.chapterlist.extra-sls-architecture id="extra-sls-architecture" %}
          <a class="expand"><span>Show all chapters</span></a>
        </div>
      </div>

      <div class="part">
        <div id="extra-credit" class="header">
          <h3>Extra Credit</h3>
          <p>Standalone chapters on specific topics for reference.</p>
        </div>
        <div class="chapters">
          {% include toc-chapters.html items=site.data.chapterlist.extra-backend id="extra-backend" %}
          {% include toc-chapters.html items=site.data.chapterlist.extra-user-mgmt id="extra-user-management" %}
          {% include toc-chapters.html items=site.data.chapterlist.extra-frontend id="extra-frontend" %}
          <a class="expand"><span>Show all chapters</span></a>
        </div>
      </div>
    </div>
  </div>

</div>
