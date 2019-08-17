---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
images:
    - images/og/policy.png
disqus_identifier: "{{ replace .Name "-" " " | md5 }}"
disqus_title: "{{ replace .Name "-" " " | title }}"
type: policy
showComments: false
---

