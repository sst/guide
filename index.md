---
layout: lander
description: Free step-by-step tutorials for creating full-stack apps with Serverless Framework and React.js. Build a Serverless REST API with our Serverless tutorial and connect it to a React single-page application with our React.js tutorial. Use our AWS tutorial with screenshots to deploy your full-stack app.
---

<div id="table-of-contents" class="table-of-contents">

  <div class="header"><h6>Table of Contents</h6></div>

  <div class="wrapper">

    <div class="col1">
      <div class="part">
        <div id="part-1" class="header">
          <h3>Part I - The Basics</h3>
          <p>Build your first Serverless app using AWS Lambda and React.</p>
        </div>
        <div class="chapters part-1">
          {% include toc-chapters.html items=site.data.chapterlist.preface id="preface" %}

          {% include toc-chapters.html items=site.data.chapterlist.intro-part1 id="intro-part1" %}
          {% include toc-chapters.html items=site.data.chapterlist.setup-aws id="setup-aws" %}
          {% include toc-chapters.html items=site.data.chapterlist.setup-backend id="setup-backend" %}
          {% include toc-chapters.html items=site.data.chapterlist.build-api id="build-api" %}
          {% include toc-chapters.html items=site.data.chapterlist.deploy-backend id="deploy-backend" %}
          {% include toc-chapters.html items=site.data.chapterlist.setup-react id="setup-react" %}
          {% include toc-chapters.html items=site.data.chapterlist.build-react id="build-react" %}
          {% include toc-chapters.html items=site.data.chapterlist.deploy-react id="deploy-react" %}
          <a class="expand"><span>Show all chapters</span></a>
        </div>
      </div>
    </div>

    <div class="col2">
      <div class="part">
        <div id="part-2" class="header">
          <h3>Part II - Automation</h3>
          <p>Use infrastructure as code to make your app production ready.</p>
        </div>
        <div class="chapters">
          {% include toc-chapters.html items=site.data.chapterlist.intro-part2 id="intro-part2" %}
          {% include toc-chapters.html items=site.data.chapterlist.new-backend id="new-backend" %}
          {% include toc-chapters.html items=site.data.chapterlist.infrastructure-code id="infrastructure-code" %}
          {% include toc-chapters.html items=site.data.chapterlist.stripe-api id="stripe-api" %}
          {% include toc-chapters.html items=site.data.chapterlist.unit-tests id="unit-tests" %}
          {% include toc-chapters.html items=site.data.chapterlist.serverless-deployments id="serverless-deployments" %}
          {% include toc-chapters.html items=site.data.chapterlist.connect-frontend id="connect-frontend" %}
          {% include toc-chapters.html items=site.data.chapterlist.add-billing-form id="add-billing-form" %}
          {% include toc-chapters.html items=site.data.chapterlist.react-deployments id="react-deployments" %}
          {% include toc-chapters.html items=site.data.chapterlist.conclusion id="conclusion" %}
          <a class="expand"><span>Show all chapters</span></a>
        </div>
      </div>

      <div class="part">
        <div id="extra-credit" class="header">
          <h3>Extra Credit</h3>
          <p>Learn the best practices to help you better architect your app.</p>
        </div>
        <div class="chapters">
          {% include toc-chapters.html items=site.data.chapterlist.extra-sls-architecture id="extra-sls-architecture" %}
          {% include toc-chapters.html items=site.data.chapterlist.extra-backend id="extra-backend" %}
          {% include toc-chapters.html items=site.data.chapterlist.extra-user-mgmt id="extra-user-management" %}
          {% include toc-chapters.html items=site.data.chapterlist.extra-frontend id="extra-frontend" %}
          <a class="expand"><span>Show all chapters</span></a>
        </div>
      </div>
    </div>
  </div>

</div>
