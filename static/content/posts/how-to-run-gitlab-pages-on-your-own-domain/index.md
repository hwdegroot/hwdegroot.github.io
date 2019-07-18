---
title: How to run and deploy gitlab pages on your own domain
tags:
    - development
    - gitlab
    - google domains
    - let's encrypt
    - en
date: 2019-07-18
images:
    - images/og/gitlab+letsencrypt.png
---


A while ago google made the [.dev](https://domains.google/#/) domains available for hosting your website.
From $12 you can buy your own domain, and start doing awesome stuff with this.

But you will still need a place to host this. Ofcourse nowadays hosting is also not that much of a problem
anymore. There are plenty of cloud providers that will host your website for you, like [AWS](https://aws.amazon.com/), [Netlify](https://www.netlify.com)
and many more.

But I am a huge fan of [gitlab](https://gitlab.com). Especially because they support private repos for free.

So in my case, I want to write my pages in markdown. A great tool for creating static sites from markdown is [hugo](https://gohugo.io/), also
it gives you [great themes](https://themes.gohugo.io/) out of the box. FOr my site I used [m10c](https://themes.gohugo.io/hugo-theme-m10c/).

My config is as follows

```yaml
title: Rik de Groot
baseURL: https://www.forsure.dev/
enableRobotsTXT: true
languageCode: en-us
assetsDir: content/assets
themesDir: themes
metaDataFormat: yaml
permalinks:
    posts: /-/:year/:month/:day/:title
    tags: /:slug
paginate: 10
theme: m10c
enableGitInfo: true
googleAnalytics: <GA tracking code>

# enable auto code highlighting
pygmentsCodefencesGuessSyntax: true
pygmentsUseClasses: true
pygmentsStyle: monokai
pygmentsCodeFences: true

# Site parameters
params:
    author: Rik de Groot
    description: Code, cook and bake. Working @easeeonline
    avatar: assets/images/rik-de-groot.jpg
    images:
        - assets/og/cover.png
    social:
        - name: gitlab
          url: https://gitlab.com/hwdegroot
        - name: twitter
          url: https://twitter.com/hwdegroot
        - name: linkedin
          url: https://www.linkedin.com/in/rikhwdegroot/
    ## Use the green styles
    style:
        darkestColor: "#282e37"
        darkColor: "#3d434c"
        primaryColor: "#67eba2"
        lightColor: "#d3d3d3"
        lighestColor: "#fff"
```

You can find all about deploying a hugo app to gitlab pages in [this example](https://gitlab.com/pages/hugo).
I used the following `.gitlab-ci.yml` configuration to get the job done


```yaml
# .gitlab-ci.yml
stages:
    - build
    - pages

variables:
    GIT_SUBMODULE_STRATEGY: recursive

.deploy:
    stage: build
    image: registry.gitlab.com/pages/hugo:latest
    before_script:
        - apk add --update git ca-certificates
        - git clean -ffdx

pages:
    extends: .deploy
    stage: pages
    script:
        - hugo --contentDir content/
          --config config/config.yaml
          --destination public/
    artifacts:
        paths:
            - public
        only:
            - tags
            - master
        when: manual
```


// configure gitlab pages to redirect
{{< image "images/configure-gitlab-pages-domain" Fit "600x" />}}

// configure letsencrypt
Gitlab has this great help on how to use [let's encrypt](https://letsencrypt.org/) in combination with [gitlab pages](https://docs.gitlab.com/ee/user/project/pages/).
Following the steps listed here will get you all you need to register your https certificater to If you follow that

// add url to gitlab pages
