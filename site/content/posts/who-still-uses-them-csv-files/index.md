---
title: "Who Still Uses Them CSV Files??!1"
date: 2020-12-16T10:31:34Z
type: post
tags:
    - development
    - lang-en
    - i-am-lazy
    - automation
images:
    - images/og/cover.png
disqus_identifier: "7cd472f4fcaf2721f794b48eebd6d414"
disqus_title: "Who Still Uses Them Csv Files"
showComments: true

---

The Problem
---

Every now and then, for work, I have to provide data to a translation agency, because we need to support
what we do in yet another language.
It is important that we can reach more users in their native language.

This is not always as straightforward as it seems. The application is running multiple services in at least the
same amount of tech stacks. In the one repository, our _language files_ are deeply nested JSON files. In yet another
repository it's PHP files containing nested associative arrays.

So a single request from the translation agency to provide all the English texts sounds simple. But what they mean is

> Can you send an excel spread sheet with the english texts in a column, so we can run it through Google Translate

They will not be happy with sending them a zip file with PHP and JSON files, with the request to please not {{< censor >}}f*ck up{{< /censor >}} the
_keys_, because otherwise the implementation on our side is screwed.

But the down side of a spreadsheet is the limitation to the amount of dimensions: 2.
Also, it is really convinient to persist the keys, because not for every languange there is a native speaking developer at hand,
who understands what these translations mean. And matching them back to the keys would be impossible (if we would even want to).
And then additionally copy-pasting data ack and forth is not what makes someone happy (some hypocracy here, since that is what we
actually do most of the time).

So lets solve the first problem of the dimensions by using dot-seperated keys. Basically this means that a nested file is turned in to a
flat `key: value` file, where the nesting is represented by dots in the keys, like so

```js
{
    a: {
        b: {
            c: [
                1,
                'f',
                g: {
                    't'
                }
            ]
        }
    }
}
```

will be turned into

| key       | value |
|:--------- |:----- |
| a.b.c.0   | 1     |
| a.b.c.1   | 'f'   |
| a.b.c.2.g | 't'   |

Where we just simply use indexes for arrays.

Having this, we have something that we can provide to external parties. We leave the english text in for them. As long as they
just ignore the keys, all should be fine.

When it is done, they will return something with the reference still to the keys (we explicitly ask them to not remove the
column with the dot-seperated keys from the file, so it can be easiy mapped onto the intial values).

Then all that needs to be done is to unflatten the dot-seperated keys, ans transform it back into the PHP or JSON file.

The solution (at least for me; hope it helps...)
---

So I created a [php-json-tool](http://php-json-tool.herokuapp.com/) utility for this. Just call it with curl. Provide your
file and the output format (check the examples). All data is streamed here, and nothing is stored, nor tracked.

If you prefer to do it yourself, feel free to run locally, fork, or provide feedback.
The sources are on Gitlab: https://gitlab.com/hwdegroot/php-json-tool

Now, all that needs to be done, is put the file in the correct location. If not specified so already in the request (using `--output` in `curl`).

Stay Safe!

