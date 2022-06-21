---
layout: lander
description: "Serverless Stack (SST) is a framework that makes it easy to build serverless applications by allowing you to test your Lambda functions live. Check out our examples to get started. Or follow our step-by-step tutorials for creating full-stack apps with serverless and React.js on AWS."
---

<header class="lander-header" role="banner">

  <div class="header-wrapper">

    <!--
    <a class="site-announcement" href="https://www.youtube.com/watch?v=wBTDkLIyMhw">
      <span class="new">New</span>
      <span class="copy">Tune in live to the `create sst` launch</span>
      <i class="fa fa-angle-right" aria-hidden="true"></i>
    </a>
    -->

    <div class="site-description">
      <h1 class="site-description">Making it easy to build full-stack serverless apps</h1>
      <img src="/assets/lander/graphics/hero-scribble.svg" />
      <img src="/assets/lander/graphics/hero-sparkle.svg" />
    </div>

    <h4 class="site-description-full">
      Serverless Stack (SST) is an open-source serverless application platform that deploys to your AWS account, helping you go from idea to IPO.
    </h4>

    <div class="controls">
      <a class="sst-button primary" href="{{ site.docs_url }}{{ site.docs_get_started }}">
        Get Started
      </a>
      <a class="sst-button secondary" href="#guide">Read the Guide</a>
    </div>

  </div>

</header>

<div class="features wrapper ">

  <div class="content">

    <div class="quick-start">
      <div class="navbar">
        <div class="controls">
          <div class="button"></div>
          <div class="button"></div>
          <div class="button"></div>
        </div>
      </div>
      <div class="code-block">
        <div class="token-line">
          <span class="token lead">#</span><span class="token dim">Create a new SST app</span>
        </div>
        <div class="token-line">
          <span class="token lead">$</span> npx <span class="token keyword">create-sst</span> my-app
        </div>
        <div class="token-line">
          <span class="token lead">$</span> cd my-app
        </div>
        <br />
        <div class="token-line">
          <span class="token lead">#</span><span class="token dim">Start Live Lambda Dev</span>
        </div>
        <div class="token-line">
          <span class="token lead">$</span> npx <span class="token keyword">sst</span> <span class="token plain">start</span>
        </div>
        <br />
        <div class="token-line">
          <span class="token lead">#</span><span class="token dim">Open the SST Console</span>
        </div>
        <div class="token-line">
          <span class="token lead">$</span> <span class="token">open</span> <span class="token plain">console.serverless-stack.com</span>
        </div>
        <br />
        <div class="token-line">
          <span class="token lead">#</span><span class="token dim">Deploy to prod</span>
        </div>
        <div class="token-line">
          <span class="token lead">$</span> npx <span class="token keyword">sst</span> <span class="token plain">deploy</span> --stage prod
        </div>
      </div>
    </div>

    <div class="list">
      <div class="feature live">
        <img src="/assets/lander/graphics/bolt-icon.svg" />
        <hr />
        <h4>Live Lambda Development</h4>
        <p>Work on your local Lambda functions live, without mocking or redeploying your app.</p>
      </div>
      <div class="columns">
        <div class="feature cdk">
          <img src="/assets/lander/graphics/parts-icon.svg" />
          <hr />
          <h4>Composable serverless constructs</h4>
          <p>Higher-level CDK constructs made specifically for building serverless apps.</p>
        </div>
        <div class="feature console">
          <img src="/assets/lander/graphics/console-icon.svg" />
          <hr />
          <h4>Easy to use console</h4>
          <p>Manage the resources in your application with the SST Console.</p>
        </div>
      </div>
    </div>

  </div>

</div>

<div id="examples" class="sections examples wrapper ">

  <div class="title">
    <h2>Build <span>full-stack</span> apps</h2>
    <br />
    <p>
      Quick start examples to help you build the type of Serverless Stack app you want.
      <a class="more" href="{% link _examples/index.md %}">
        View all the examples <i class="fa fa-angle-right" aria-hidden="true"></i>
      </a>
    </p>
    <img src="/assets/lander/graphics/examples-scribble.svg" />
  </div>

  <div class="content">
    {% include lander-examples.html %}
  </div>
</div>

<div class="sections breakpoints wrapper ">

  <div class="title">
    <h2><span>Test</span> your apps <span>live</span></h2>
    <br />
    <p>
      Set breakpoints in your Lambda functions and test your apps live.
      <a class="more" href="{% link _examples/how-to-debug-lambda-functions-with-visual-studio-code.md %}">
        Learn more <i class="fa fa-angle-right" aria-hidden="true"></i>
      </a>
    </p>
    <img src="/assets/lander/graphics/breakpoints-swirl.svg" />
  </div>

  <div class="content">
    <svg viewBox="0 0 2684 1366" xmlns="http://www.w3.org/2000/svg">
      <image x="432" y="0" width="2252" height="1366" href="/assets/lander/graphics/breakpoints-image.png" />
    </svg>
    <svg viewBox="0 0 760 522" xmlns="http://www.w3.org/2000/svg">
      <image x="30" y="0" width="714" height="522" href="/assets/lander/graphics/breakpoints-image-mobile.png" />
    </svg>
  </div>

</div>

<div class="sections console wrapper">

  <div class="title">
    <h2>Easy to use <span>console</span></h2>
    <br />
    <p>
      Manage your resources, invoke functions, and view your logs live.
      <a class="more" href="{{ site.docs_url }}/console">
        Learn more <i class="fa fa-angle-right" aria-hidden="true"></i>
      </a>
    </p>
    <img src="/assets/lander/graphics/console-sparkle-left.svg" />
    <img src="/assets/lander/graphics/console-sparkle-right.svg" />
  </div>

  <div class="content">
    <svg viewBox="0 0 2640 1123" xmlns="http://www.w3.org/2000/svg">
      <image x="54" y="0" width="2546" height="1123" href="/assets/lander/graphics/console-image.png" />
    </svg>
    <svg viewBox="0 0 747 577" xmlns="http://www.w3.org/2000/svg">
      <image x="0" y="0" width="739" height="577" href="/assets/lander/graphics/console-image-mobile.png" />
    </svg>
  </div>

</div>

<div class="sections cdk wrapper ">

  <div class="title">
    <h2><span>The power of </span>AWS<span></span></h2>
    <br />
    <p>
      Built on CDK and the battle-tested CloudFormation. Natively use all AWS services.
      <a class="more" href="{{ site.docs_url }}/faq#can-i-use-all-the-cdk-constructs-in-sst">
        Learn more <i class="fa fa-angle-right" aria-hidden="true"></i>
      </a>
    </p>
    <img src="/assets/lander/graphics/cdk-sparkle.svg" />
  </div>

  <div class="content">
    <svg viewBox="0 0 2638 926" xmlns="http://www.w3.org/2000/svg">
      <image x="139" y="0" width="2098" height="926" href="/assets/lander/graphics/cdk-image.png" />
    </svg>
    <svg viewBox="0 0 764 471" xmlns="http://www.w3.org/2000/svg">
      <image x="7" y="0" width="743" height="471" href="/assets/lander/graphics/cdk-image-mobile.png" />
    </svg>
  </div>

</div>

<div id="case-studies" class="case-studies wrapper ">
  <div class="content">
    <h3>Case Studies</h3>
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

<div class="testimonials">
  <div class="title">
    <h2>
      Making it easy <span>to build full-stack</span> serverless apps
      <img src="/assets/lander/graphics/testimonials-sparkle.svg" />
    </h2>
  </div>

  <div class="scroll-content">
    <div class="tweets">
      {% for tweet in site.data.testimonials.tweets %}
        <div class="tweet">
          <i class="fa fa-twitter" aria-hidden="true"></i>
          <div class="author">
            <img src="/assets/lander/testimonials/{{ tweet.username }}.jpg" />
            <div>
              <p>{{ tweet.name }}</p>
              <p>@{{ tweet.username }}</p>
            </div>
          </div>
          <div class="content">{{ tweet.content }}</div>
          <a class="tweet-link" target="_blank" href="{{ tweet.link }}"></a>
        </div>
      {% endfor %}
      <div class="spacer"></div>
    </div>
    <div class="scroll-shadow left"></div>
    <div class="scroll-shadow right"></div>
  </div>

  <div class="controls">
    <a class="sst-button primary" href="{{ site.docs_url }}{{ site.docs_get_started }}">
      Get Started
    </a>
    <a class="sst-button secondary" href="#guide">Read the Guide</a>
  </div>

</div>

<div class="community wrapper ">
  <div class="content">
    <h4>Join our <span>growing community</span></h4>
    <ul>
      <li>
        <h6>{{ site.stats.github }}+</h6>
        <p>GitHub stars</p>
      </li>
      <li>
        <h6>{{ site.stats.slack }}+</h6>
        <p>Slack members</p>
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
    <h2>Serverless Stack Guide</h2>
    <h4>
      The most widely read resource for building full-stack apps using serverless and React on AWS.
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

  <div class="readers">
    {% include reader-logos.html %}
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
