---
layout: lander
description: "Build modern full-stack serverless applications on AWS with Next.js, Remix, Astro, Solid, and more."
---

<header class="lander-header" role="banner">

  <div class="header-wrapper">

    <a class="site-announcement" href="{% link _posts/2023-04-17-open-next-v1.md %}">
      <span class="new">New</span>
      <span class="copy">OpenNext 1.0 is out. Learn more</span>
      <i class="fa fa-angle-right" aria-hidden="true"></i>
    </a>

    <div class="site-description">
      <h1 class="site-description">Build modern full-stack applications on AWS</h1>
      <img src="/assets/lander/graphics/hero-scribble.svg" />
      <img src="/assets/lander/graphics/hero-sparkle.svg" />
    </div>

    <h4 class="site-description-full">
      1. Deploy Next.js, Remix, or Astro to AWS.<br />
      2. Add any backend feature.<br />
      3. Go from idea to IPO!
    </h4>

    <div class="controls">
      <a data-text="npm create sst@latest" class="command sst-button secondary">
        <span>npm create sst</span>
        <i class="fa fa-copy" aria-hidden="true"></i>
        <i class="fa fa-check" aria-hidden="true"></i>
      </a>
      <a class="sst-button primary" href="{{ site.docs_url }}">
        Get Started
      </a>
    </div>

  </div>

</header>

<div class="logos wrapper">
  <h5>Loved by over 1,000 amazing teams</h5>
  <ul>
    <li title="Amazon" class="amazon">{% include svg/amazon.svg %}</li>
    <li title="Analog Devices" class="ad">{% include svg/analog-devices.svg %}</li>
    <li title="Shell" class="shell">{% include svg/shell.svg %}</li>
    <li title="Comcast" class="comcast">{% include svg/comcast.svg %}</li>
    <li title="HBO" class="hbo">{% include svg/hbo.svg %}</li>
  </ul>
</div>

<div id="frontend" class="sections frontend wrapper">

  <div class="title">
    <h2>Start<span> with your favorite</span> frontend</h2>
    <br />
    <p>Use our open source framework to deploy your Next.js, Remix, Astro, or Solid site.</p>
    <img src="/assets/lander/graphics/frontend-scribble.svg" />
  </div>

  <div class="content">
    {% include lander-examples/frontend-list.html %}
  </div>

  <div class="timeline"><div></div></div>
</div>

<div class="sections backend wrapper">

  <div class="title">
    <h2>Add <span>any backend</span> feature</h2>
    <br />
    <p>
      Extend your app with our preconfigured backend components. Even use any AWS service.
    </p>
    <img src="/assets/lander/graphics/backend-swirl.svg" />
  </div>

  <div class="timeline"><div></div></div>

  <div class="content databases">
    {% include lander-examples/database.html %}
    <div class="spine">
      <div class="timeline"><div></div></div>
      <div class="point"></div>
      <div class="timeline"><div></div></div>
    </div>
    <div class="copy">
      <figure><i class="fa fa-database" aria-hidden="true"></i></figure>
      <h3>Database</h3>
      <p>Add a serverless SQL or NoSQL database to power your app.</p>
    </div>
  </div>

  <div class="content apis">
    <div class="copy">
      <figure>{% include svg/graphql.svg %}</figure>
      <h3>GraphQL API</h3>
      <p>Add a dedicated serverless GraphQL or REST API to your app.</p>
    </div>
    <div class="spine">
      <div class="timeline"><div></div></div>
      <div class="point"></div>
      <div class="timeline"><div></div></div>
    </div>
    {% include lander-examples/api.html %}
  </div>

  <div class="content auth">
    {% include lander-examples/auth.html %}
    <div class="spine">
      <div class="timeline"><div></div></div>
      <div class="point"></div>
      <div class="timeline"><div></div></div>
    </div>
    <div class="copy">
      <figure><i class="fa fa-key" aria-hidden="true"></i></figure>
      <h3>Auth</h3>
      <p>Authenticate your users through any auth provider.</p>
    </div>
  </div>

  <div class="content cron">
    <div class="copy">
      <figure><i class="fa fa-clock-o" aria-hidden="true"></i></figure>
      <h3>Cron jobs</h3>
      <p>Run cron jobs powered by serverless functions.</p>
    </div>
    <div class="spine">
      <div class="timeline"><div></div></div>
      <div class="point"></div>
      <div class="timeline"><div></div></div>
    </div>
    {% include lander-examples/cron.html %}
  </div>

  <div class="content all">
    {% include lander-examples/all.html %}
    <div class="spine">
      <div class="timeline"><div></div></div>
      <div class="point"></div>
      <div class="timeline"><div></div></div>
    </div>
    <div class="copy">
      <figure>{% include svg/aws.svg %}</figure>
      <h3>Any AWS service&hellip;</h3>
      <p>Go beyond our components and integrate with any AWS service!</p>
    </div>
  </div>

  <div class="timeline"><div></div></div>

</div>

<div class="sections collaborate wrapper">

  <div class="title">
    <h2>Collaborate <span>with your team</span></h2>
    <br />
    <p>Create preview or feature environments. Or one for everyone on your team.</p>
    <img src="/assets/lander/graphics/collaborate-sparkle.svg" />
  </div>

  <div class="timeline"><div></div></div>

  <div class="content deploy">
    {% include lander-examples/deploy.html %}
    <div class="spine">
      <div class="timeline"><div></div></div>
    </div>
    <div class="copy">
      <figure><i class="fa fa-terminal" aria-hidden="true"></i></figure>
      <h3>Environments from the CLI</h3>
      <p>Use the CLI to create and deploy to new environments.</p>
    </div>
  </div>

  <div class="content seed">
    {% include lander-examples/preview-deploys.html %}
    <div class="spine">
      <div class="timeline"><div></div></div>
    </div>
    <div class="copy">
      <figure><i class="fa fa-code-fork" aria-hidden="true"></i></figure>
      <h3>Automatic preview environments</h3>
      <p>Get preview environments for every PR or branch with <a href="https://seed.run" target="_blank"><b><i>SEED</i></b></a>.</p>
    </div>
  </div>

  <div class="timeline"><div></div></div>

</div>

<div class="learn-more wrapper">
  <a class="sst-button primary" href="{{ site.docs_url }}">
    Get Started
  </a>
</div>

<div id="case-studies" class="case-studies wrapper">
  <div class="content">
    <h3>Testimonials</h3>
    <div class="slideshow-container">
      <div class="slideshow">
        <ul>
          <li class="case-study">
            <div class="author">
              <img src="/assets/lander/case-studies/profile-doorvest.png" />
              <div class="content">
                <p>Lead Engineer,</p>
                <p><a href="https://doorvest.com">Doorvest</a></p>
              </div>
            </div>
            <h5 class="quote">&ldquo;SST has improved our productivity by at least 3 times.&rdquo;</h5>
            <a class="logo" href="https://doorvest.com"><img width="138px" src="/assets/lander/case-studies/logo-doorvest.svg" /></a>
            <a class="sst-button primary" href="{% link _posts/2021-10-27-doorvest-is-using-sst-to-simplify-real-estate-investing.md %}">Read Case Study</a>
          </li>
          <li class="case-study">
            <div class="author">
              <img src="/assets/lander/case-studies/profile-hs1.jpeg" />
              <div class="content">
                <p>Engineering Manager,</p>
                <p><a href="https://henryscheinone.com">Henry Schein One</a></p>
              </div>
            </div>
            <h5 class="quote">&ldquo;We have gone all-in on SST.&rdquo;</h5>
            <a class="logo" href="https://henryscheinone.com"><img width="150px" src="/assets/lander/case-studies/logo-hs1.svg" /></a>
            <a class="sst-button primary" href="{% link _posts/2021-11-16-henry-schein-one-the-worlds-largest-dental-practice-management-software-company-is-building-with-sst.md %}">Read Case Study</a>
          </li>
          <li class="case-study">
            <div class="author">
              <img src="/assets/lander/case-studies/profile-leadent.jpeg" />
              <div class="content">
                <p>CTO,</p>
                <p><a href="https://leadent.digital">Leadent Digital</a></p>
              </div>
            </div>
            <h5 class="quote">&ldquo;I hadn't found anything like SST.&rdquo;</h5>
            <a class="logo" href="https://leadent.digital"><img width="90px" src="/assets/lander/case-studies/logo-leadent.png" /></a>
            <a class="sst-button primary" href="{% link _posts/2021-11-11-leadent-digital-is-transforming-field-service-operations-with-sst.md %}">Read Case Study</a>
          </li>
          <li class="case-study">
            <div class="author">
              <img src="/assets/lander/case-studies/profile-buildforce.png" />
              <div class="content">
                <p>Founder,</p>
                <p><a href="https://buildforce.com">Buildforce</a></p>
              </div>
            </div>
            <h5 class="quote">&ldquo;We were blown away by the local development environment.&rdquo;</h5>
            <a class="logo" href="https://buildforce.com"><img width="135px" src="/assets/lander/case-studies/logo-buildforce.png" /></a>
            <a class="sst-button primary" href="{% link _posts/2021-10-28-buildforce-is-creating-the-first-ever-career-platform-for-the-construction-trade-with-sst.md %}">Read Case Study</a>
          </li>
        </ul>
      </div>
      <button class="prev"><img src="/assets/lander/graphics/chevron-icon.svg" /></button>
      <button class="next"><img src="/assets/lander/graphics/chevron-icon.svg" /></button>
    </div>
  </div>
</div>

<div class="community wrapper">
  <div class="content">
    <h4>Join our <span>growing community</span></h4>
    <ul>
      <li>
        <h6>{{ site.stats.github_short}}+</h6>
        <p>GitHub stars</p>
      </li>
      <li>
        <h6>{{ site.stats.discord }}+</h6>
        <p>Discord members</p>
      </li>
      <li>
        <h6>{{ site.stats.newsletter_short }}+</h6>
        <p>Subscribers</p>
      </li>
    </ul>
  </div>
</div>

<div id="guide" class="guide">
  <div class="title">
    <h2>SST Guide</h2>
    <h4>
      The most widely read resource for building full-stack apps using serverless on AWS.
    </h4>
  </div>

  <div class="form-container">
    <div class="form-copy">
      <p>Download the FREE 1000 page ebook</p>
      <p>Join {{ site.stats.newsletter }} readers from the biggest companies in the world. We'll also send you updates when new versions are published.</p>
    </div>
    <div class="form">
      {% include email-octopus-form.html button_copy="Download" source="home" %}
    </div>
    <img class="sparkle-left" src="/assets/lander/graphics/guide-sparkle-left.svg" />
    <img class="sparkle-right" src="/assets/lander/graphics/guide-sparkle-right.svg" />
  </div>

</div>

<div id="table-of-contents" class="table-of-contents">

  <div class="wrapper">
    <div class="chapters">
      {% include toc-chapters.html items=site.data.chapterlist.preface id="preface" index="1" %}

      {% include toc-chapters.html items=site.data.chapterlist.intro id="intro" index="2" %}

      {% include toc-chapters.html items=site.data.chapterlist.setup-aws id="setup-aws" index="3" %}
      {% include toc-chapters.html items=site.data.chapterlist.setup-sst id="setup-sst" index="4" %}
      {% include toc-chapters.html items=site.data.chapterlist.setup-sst-backend id="setup-sst-backend" index="5" %}
      {% include toc-chapters.html items=site.data.chapterlist.build-sst-api id="build-sst-api" index="6" %}
      {% include toc-chapters.html items=site.data.chapterlist.add-auth-stack id="add-auth-stack" index="7" %}
      {% include toc-chapters.html items=site.data.chapterlist.handling-secrets id="handling-secrets" index="8" %}
      {% include toc-chapters.html items=site.data.chapterlist.unit-tests id="unit-tests" index="9" %}
      {% include toc-chapters.html items=site.data.chapterlist.cors-sst id="cors-sst" index="10" %}

      {% include toc-chapters.html items=site.data.chapterlist.setup-react id="setup-react" index="11" %}
      {% include toc-chapters.html items=site.data.chapterlist.react-routes id="react-routes" index="12" %}
      {% include toc-chapters.html items=site.data.chapterlist.setup-amplify id="setup-amplify" index="13" %}
      {% include toc-chapters.html items=site.data.chapterlist.build-react id="build-react" index="14" %}
      {% include toc-chapters.html items=site.data.chapterlist.secure-pages id="secure-pages" index="15" %}

      {% include toc-chapters.html items=site.data.chapterlist.custom-domains id="custom-domains" index="16" %}
      {% include toc-chapters.html items=site.data.chapterlist.automating-serverless-deployments id="automating-serverless-deployments" index="17" %}
      {% include toc-chapters.html items=site.data.chapterlist.monitor-debug-errors id="monitor-debug-errors" index="18" %}

      {% include toc-chapters.html items=site.data.chapterlist.conclusion id="conclusion" index="19" %}
      <a class="expand" href="{% link guide.md %}"><span class="sst-button tertiary">Show all</span></a>
    </div>

  </div>

</div>
