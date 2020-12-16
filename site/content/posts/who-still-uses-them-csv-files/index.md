---
title: "Who Still Uses Them Csv Files"
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

Every now and then, for work, I have to provide data to a translation agency because we need to support
what we do in yet another language, so we can reach more users in their native language.

This is not always as straightforward. We have a tech stack at work where in the one repository our language files are
managed as JSON files. In yet another repoitory it is PHP files containing nested associate arrays.

So a single request from the translation agency to provide all the English texts, cannot be responded with a JSON file
and a nice smile, let alone a PHP file.

So, a better way to provide this is, ow yes, a spread sheet. But the down side of a spreadsheet is the amount of dimensions.
Where we are pretty unlimited with our JSON and PHP files, in the spreadsheet we have two dimensions only.

And then the next problem is, that when this is all translated (into a language that doesn't mean anything to me),
it must be possible to transform this back into something that is supported by the programming language or framework we use.

And then last but not least, I hate manual work.

So lets solve the first problem of the dimensions by using dot-seperated keys. Basically this means that we turn a
nested key into a string seperated by dots.

```json
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

Having this, we have something that we can provide to external parties. We leave the english text in for them.

When it is done, they will return something with the reference still to the keys (we explicitly ask them to not remove the
column with the dot-seperated keys from the file, so it can be easiy mapped onto the intial values.

Then all that needs to be done is to unflatten the dot-seperated keys, ans transform it back into the PHP or JSON file.

So I created a [php-json-tool](http://php-json-tool.herokuapp.com/) utility for this. Just call it with curl. Provide your
file and the output format (check the examples). All data is streamed here, and nothing is stored.

If you prefer to do it yourself, feel free to run locally, fork, or provide feedback. The sources are on Gitlab https://gitlab.com/hwdegroot/php-json-tool

Now, all you need to do is put the file in the correct location. If you did not do so already by specifying the output name.

Stay Safe!

