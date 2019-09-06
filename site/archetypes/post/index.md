---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
type: post
tags:
    - development
    - lang-en
images:
    - images/og/cover.png
disqus_identifier: "{{ replace .Name "-" " " | md5 }}"
disqus_title: "{{ replace .Name "-" " " | title }}"
showComments: true
---

