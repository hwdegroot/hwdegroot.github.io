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



Not so long ago I had to make a static website, and was figuring out how to do this. I came across [hugo](https://gohugo.io). And I
really liked how quickly you can build a website from markdown.

A while ago google made the [.dev](https://domains.google/#/), so impulsively, I bought one.
From $12 you can get one, and start doing awesome stuff with this. But I didn't.
There are plenty of cloud providers that will host your website for you, like [AWS](https://aws.amazon.com/), [Netlify](https://www.netlify.com)
and many more.

But I had no clue where to host this, because I am lazy and cheap. Then for work I had to do something similar, and I wondered if I could just host
my [GitLab Pages](https://docs.gitlab.com/ee/user/project/pages/) on my own domain. And guess what, you can, and it is amazingly simple!

So in my case, I want to write my pages in markdown. A great tool for creating static sites from markdown is [hugo](https://gohugo.io/), also
it gives you [great themes](https://themes.gohugo.io/) out of the box. FOr my site I used [m10c](https://themes.gohugo.io/hugo-theme-m10c/).

You can find the repository of this site [here](https://gitlab.com/hwdegroot/forsure.dev). I like `yaml` over `toml`, so I will use the `yaml` configuration option
from hugo.

My config is as follows, but also available [here](https://gitlab.com/hwdegroot/forsure.dev/blob/master/static/config/config.yaml)

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

You can find all about deploying a hugo app to GitLab pages in [this example](https://gitlab.com/pages/hugo).
I used the following `.gitlab-ci.yml` configuration to get the job done. Gitlab published a [docker container](https://registry.gitlab.com/pages/hugo:latest),
that can be used to build your project. But I like to have the extended features as well, so [I created my own](https://gitlab.com/hwdegroot/forsure.dev/blob/master/Dockerfile) which is available in the container registry of the project `registry.gitlab.com/hwdegroot/forsure.dev/hugo:latest`, which is based on the container from [jguyomard](https://github.com/jguyomard). You can find the project on [GitHub](https://github.com/jguyomard/docker-hugo).


```yaml
# .gitlab-ci.yml
stages:
    - build
    - pages

variables:
    GIT_SUBMODULE_STRATEGY: recursive

.deploy:
    stage: build
    image: registry.gitlab.com/hwdegroot/forsure.dev/hugo:latest
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

Now that you build your static site in GitLab, and deploy it to GitLab Pages, you can add your own domain to
GitLab pages by following a few steps.

Add your domain to GitLab Pages
--

Now we can add the domain to GitLab Pages. In your project, go to `Settings` > `Pages`. Here click the `New domain` button.

Fill in your domain, and set the `Automatic certificate management using Let's Encrypt` switch on.

{{< imgproc "images/configure-gitlab-pages-domain" Fit "600x" >}}
Configure your own domain in GitLab Pages settings.
{{< /imgproc >}}

Verify your domain
---

To verify your domain, you will need to add two fields to your DNS. I am using [Google domains](https://domains.google), but it is all more or less the same.
All you need is privileges to alter the DNS settings of your domain.

Youl will have to add two records, so GitLab can verify you own the domain.

First you will have to add a `CNAME` record `<www.yourdomain.dev> CNAME <yourusername>.gitlab.io.` to forward the url to gitlab pages,
and a `TXT` record to verify the domain is yours `_gitlab-pages-verification-code.www.yourdomain.dev TXT gitlab-pages-verification-code=<somerandomcode>`.

{{< image "images/configure-google-dns" Fit "600x600" >}}
Configure dns records in google domains.
{{< /imgproc >}}

Then hit the `verify` button. It might not work straight away because the records need to be synced. But in my case it was less than 5 minutes.

{{< image "images/gitlab-pages-domain-verify" Fit "600x600" >}}
Verify that the domain is yours after adding the verification code to your DNS
{{< /imgproc >}}

If it worked, the status will change to verified

{{< image "images/gitlab-pages-domain-verified" Fit "600x600" >}}
Domain verified by GitLab.
{{< /imgproc >}}

And in the overview, you will see that your domain is listed in the `Access pages section`

{{< image "images/gitlab-pages-domain-added" Fit "600x600" >}}
Domain added to GitLab Pages.
{{< /imgproc >}}

Add a let's encrypt certificate to your page
--

Gitlab has this great help on how to use [let's encrypt](https://letsencrypt.org/) in combination with [GitLab Pages](https://docs.gitlab.com/ee/user/project/pages/).
Following the steps listed here will get you all you need to register your https certificate to your domain.

You're done!

Hope it helps

