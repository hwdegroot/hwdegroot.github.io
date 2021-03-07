---
title: "Add Search Functionality to Your Hugo Static Site"
date: 2019-09-03T07:26:47Z
tags:
    - development
    - lang-en
    - hugo
    - lunrjs
    - search
images:
    - images/og/cover.png
disqus_identifier: "b41840651158f972d21cb59b5cce4952"
disqus_title: "Add Search Functionality to Your Hugo Static Site"
type: post
showComments: true
---

When I was working on a static site, generated with hugo, the amount of pages started to get really
out of hand. I was looking for pages, but wasn't entirely sure where to look for them. This was the
point that it crossed my mind that searching the site would be extremely convenient.

So my first thought was, let's install a search package. However this was not as available as I initially
thought. Hugo has [some docs on search functionality](https://gohugo.io/tools/search/), however none of them give a full
implementation example. This post will.

## The problem

Static sites are generated into all available paths, and then those files are served. The server won't be
running a nice database that you can query for some content. This means that the database that will be used for
searching has to be generated as well. In this example that database will be a generated `json` file that will be served
over the path `/search`.


## Getting started

Here I will describe the functionality that is available on this site. It will use [lunrjs](https://lunrjs.com) as a client side
search engine, that is lightweight and super easy to get started with search library.

The source is of the implementation described in this post is available [here](https://gitlab.com/hwdegroot/forsure.dev).

The solution is not exactly rocket science, but it took me some time to get it all working and integrated, so
hopefully this example will save you some time.

## What do we need

To get this up and running we are going to need 4 things

1. An endpoint that can serve the `json` database
1. A template that will generate the `json` file, so we can query it
1. A client side script that retrieves the database file, and allows searching in the file (I will use [`lunr`](https://lunrjs.com) for that
1. A search page (in this case a partial), so it is actually possible to jot down search words

### The endpoint

If you have a default layout for your hugo site, like I do, you will need to make the `/search` endpoint available. There are multiple
ways to do that, but I chose to make a directory `search` inside the content directory, containing an `index.md` file. You can see it
[here](https://gitlab.com/hwdegroot/forsure.dev/tree/master/site/content/search). The `index.md` file will contain dummy content. You can
use this to add some documentation for the team if you'd prefer. But really, what's in there doesn't matter, because the actual file won't be served.

What _is_ important is the `type` of the file. I used `data`, but it doesn't matter at this point. We will only have to make sure that we use it
when we are creating the `json` template. Make sure to put it in the [front matter](https://gohugo.io/content-management/front-matter/#readout).

Mine looks like this

```yaml
---
type: data
---
```

Make sure, to exclude the `data` type from the pages that you want people to see in the list.

In my [layouts/_default/list.html](https://gitlab.com/hwdegroot/forsure.dev/blob/master/site/layouts/_default/list.html) template that drills down to

```go
{{ range $index, $element := where .Paginator.Pages ".Type" "==" "post" }}
    ...
{{ end }}

```

because I only want to list pages of type `post`. But you can change this to

```go
{{ range $index, $element := where .Paginator.Pages ".Type" "!=" "data" }}
    ...
{{ end }}

```

You see, nothing fancy so far. Now that the `/search` endpoint is available, it's time to proceed, however hugo will error out on this, because there is no template for this
type. So let's do that next.

### Creating the data template

Because I chose the `type` to be `data` and to use a directory `search` with a file `index.md`, I created a directory `data` in
[`/content/layouts`](https://gitlab.com/hwdegroot/forsure.dev/tree/master/site/layouts/data/).
Inside this directory I put the template `single.html`. This is the file that hugo expects for a file called `index.md`. If you prefer `_index.md`
make sure to call this file `baseof.html`. If you don't want to put the search file inside a directory, but want to add `search.md` to the root of the content
dir, then call this file `list.html`.

Once this is done, you might have to restart your local hugo server, if you are running it locally like me. When that is done, there will be an empty page
when you browse `http://localhost:8888/search` (or whatever port it runs locally).

But we want this url to show a nice `json` representation of all the pages, because that we can load into [lunr][lunr-js].

### Filling the template

You can view how to fill the template [here](https://gitlab.com/hwdegroot/forsure.dev/tree/master/site/layouts/data/single.html)

The example is based on [this gist](https://github.com/goblindegook/goblindegook.com/blob/master/themes/goblindegook/layouts/data/document-index.html) from
[goblindegook](https://github.com/goblindegook/goblindegook.com).

```go
{{ $.Scratch.Add "index" slice }}

{{ $searchablePages := where .Site.Pages "Params.type" "==" "post" }}

{{ range $index, $page := $searchablePages }}
  {{ .Scratch.Set "pageData" "" }}
  {{ .Scratch.Set "pageContent" "" }}
  {{ .Scratch.Set "pageURL" "" }}
  {{ .Scratch.Set "pageTag" "" }}


  {{ if gt (len $page.Content) 0 }}
    {{ .Scratch.Set "pageContent" $page.Plain }}
    {{ .Scratch.Set "pageURL" $page.Permalink }}
    {{ if (isset $page.Params "tags") }}
    {{ .Scratch.Set "pageTag" (delimit $page.Params.tags " ; ") }}
    {{ end }}

    {{ .Scratch.Set "pageData" (dict "id" $index "title" $page.Title "url" (.Scratch.Get "pageURL") "content" (.Scratch.Get "pageContent") "tag" (.Scratch.Get "pageTag")) }}

    {{ $.Scratch.Add "index" (.Scratch.Get "pageData") }}
  {{ end }}
{{ end }}

{{ $.Scratch.Get "index" | jsonify }}
```

You can edit the fields to whatever you like. For convenience I set the `id` field to the incrementor of the list.

Now when you visit the `/search` endpoint, it will return `json` with the following layout

```json
[
    {
        "id": "The id generated by hugo",
        "title": "The page title",
        "url":  "Link to the page, mostly so we can link it from the search results",
        "content": "A plain text string of the content",
        "tag": "semicolon seperated string of the tags, because that makes them searchable"
    },
    ...
]
```

### Client side searching

Now we are ready to use this in the client. I am loading the json file in a promise, so it won't annoy the user when the file gets huge.
~~I will use [axios](https://www.axios.com/) for this.~~

**UPDATE:** axios has been replcaed by browser's native [`fetch`](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API).

Make sure that if you do so, and you really can't drop all the IE users, that you will need to polyfill `Promise` as well.

I don't care about IE users, so I didn't. Also I was too lazy to setup a webpack config. ~~So you will notice that the
javascript syntax is not ES5+, and~~ I will load the libraries from a cdn ([unpkg](https://unpkg.com/) in this case, but there
are plenty)

So add the following scripts to your base template if you are also lazy

#### Axios

The axios part is deprecated for my site, but if you chose to use axios, you will need to add this as well.

```html
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
```

#### Lunr

```html
<script src="https://unpkg.com/lunr/lunr.js"></script>
```

#### Polyfill for Promise

On [polyfill.io](https://polyfill.io/v3/url-builder/) you can click the bundle you want, and it will generate
a script tag for you. If you do this for `Promise` only you will get something like this

```html
<script
    crossorigin="anonymous"
    src="https://polyfill.io/v3/polyfill.min.js?flags=gated%2Calways&features=Promise"
></script>
```

If you need more, it is pretty straight-forward. Make sure that you put the polyfill as the first element after `<body>`.

I put them all in a [partial](https://gitlab.com/hwdegroot/forsure.dev/blob/master/site/layouts/partials/scripts.html), that I
load in my head (except the polyfill, because, like I said, I don't care).

So all set there, time to create a partial for the client side search. You can find the partial
[here](https://gitlab.com/hwdegroot/forsure.dev/blob/master/site/layouts/partials/search.html), but it looks like this.

```html
<div class="show-search">
    <a class="toggle-search" title="search in easee documentation">
        <svg xmlns="http://www.w3.org/2000/svg" width="612.056" height="612.057" viewbox="0 0 613 613">
            <path
                d="M595.2 513.908L493.775 412.482c26.707-41.727 42.685-91.041 42.685-144.263C536.459 120.085 416.375 0 268.24 0 120.106 0 .021 120.085.021 268.219c0 148.134 120.085 268.22 268.219 268.22 53.222 0 102.537-15.979 144.225-42.686l101.426 101.463c22.454 22.453 58.854 22.453 81.271 0 22.492-22.491 22.492-58.855.038-81.308zm-326.96-54.103c-105.793 0-191.585-85.793-191.585-191.585 0-105.793 85.792-191.585 191.585-191.585s191.585 85.792 191.585 191.585c.001 105.792-85.791 191.585-191.585 191.585z" />
        </svg>
    </a>
</div>
<aside role="search">
    <div class="close toggle-search">
        <svg height="512" width="512" viewbox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
            <path d="M443.6 387.1L312.4 255.4l131.5-130c5.4-5.4 5.4-14.2 0-19.6l-37.4-37.6c-2.6-2.6-6.1-4-9.8-4-3.7 0-7.2 1.5-9.8 4L256 197.8 124.9 68.3c-2.6-2.6-6.1-4-9.8-4-3.7 0-7.2 1.5-9.8 4L68 105.9c-5.4 5.4-5.4 14.2 0 19.6l131.5 130L68.4 387.1c-2.6 2.6-4.1 6.1-4.1 9.8 0 3.7 1.4 7.2 4.1 9.8l37.4 37.6c2.7 2.7 6.2 4.1 9.8 4.1 3.5 0 7.1-1.3 9.8-4.1L256 313.1l130.7 131.1c2.7 2.7 6.2 4.1 9.8 4.1 3.5 0 7.1-1.3 9.8-4.1l37.4-37.6c2.6-2.6 4.1-6.1 4.1-9.8-.1-3.6-1.6-7.1-4.2-9.7z"/>
        </svg>
    </div>
    <div class="search-wrapper">
        <form class="search" method="get">
            <input type="search" placeholder="search..." disabled="disabled" />
            <div class="search-documentation">
                <a href="https://lunrjs.com/guides/searching.html">Read more on how to search</a> on the <a href="https://lunrjs.com">lunrjs</a> page
            </div>
        </form>
    </div>
    <ul class="search-results">
        <li>
        </li>
    </ul>
</aside>
{{ $script := resources.Get "js/search.js" | resources.Minify | resources.Fingerprint }}
<script src="{{ $script.RelPermalink }}"></script>
```

Note that the javascript file is already included here. I will come back to that in the next paragraph


It will need some styling. Take a peek [here](https://gitlab.com/hwdegroot/forsure.dev/blob/master/site/assets/css/_search.scss).

Additionally, if you put the styling in a `scss` file, make sure to load it. The [template](https://themes.gohugo.io/hugo-book/) I am using,  allows
injection of css via an  `_extra.scss` file in the `assets/css` directory. So I just created a `_search.scss` file in the assets directory, and included
it in the [`_extra.scss`](https://gitlab.com/hwdegroot/forsure.dev/blob/master/site/assets/css/_extra.scss) like so

```scss
...
@import 'search';
...
```

### The real magic

Now the final step is to make the search work. For that, just create a javascript file in the assets directory. For me
that is [`assets/js/search.js`](https://gitlab.com/hwdegroot/forsure.dev/blob/master/site/assets/js/search.js).

It looks like this:

```js
document.addEventListener("DOMContentLoaded", () => {
    let searchResults = [];
    const searchWrapper = document.querySelector("aside[role=search]");
    const searchResultElement = searchWrapper.querySelector(".search-results");
    const searchInput = searchWrapper.querySelector("input");

    const toggleSearch = (searchWrapper, searchInput)  =>{
        if (searchWrapper.classList.contains("active")) {
            searchWrapper.classList.add("visible");
            setTimeout(() => {
                searchWrapper.classList.remove("visible");
            }, 300);
            searchWrapper.classList.remove("active");
        } else {
            searchWrapper.classList.add("active");
            searchInput.focus();
        }
    }

    document.querySelectorAll(".toggle-search").forEach(el => {
        el.addEventListener("click", e => {
            toggleSearch(searchWrapper, searchInput);
        });
    });

    window.addEventListener("keydown", e => {
        // dismiss search on  ESC
        if (e.key == "Escape" && searchWrapper.classList.contains("active")) {
            e.preventDefault();
            toggleSearch(searchWrapper, searchInput);
        }

        // open search on CTRL+SHIFT+F
        if (e.ctrlKey && e.shiftKey && e.key == "F" && !searchWrapper.classList.contains("active")) {
            e.preventDefault();
            toggleSearch(searchWrapper, searchInput);
        }
    });

    const tags = (tags, searchString) => {
        let tagHTML = (tags.split(" ; ") || [])
            .filter(i => {
                return i && i.length > 0;
            })
            .map(i => {
                return "<span class='tag'>" + mark(i, searchString) + "</span>";
            })
        return tagHTML.join("");
    }

    const mark = (content, search) => {
        if (search) {
            let pattern = /^[a-zA-Z0-9]*:/i;
            search.split(" ").forEach(s => {
                if (pattern.test(s)) {
                    s = s.replace(pattern, "");
                }

                if (s && s.startsWith("+")) {
                    s = s.substring(1);
                }

                if (s && s.indexOf("~") > 0
                    && s.length > s.indexOf("~")
                    && parseInt(s.substring(s.indexOf("~") + 1)) == s.substring(s.indexOf("~") + 1)
                ) {
                    s = s.substring(0, s.indexOf("~"));
                }

                if (!s || s.startsWith("-")) {
                    return;
                }
                let re = new RegExp(s, "i");
                content = content.replace(re, m => {
                    return "<mark>"+m+"</mark>";
                });
            });
        }

        return content;
    }

    fetch("/search")
        .then(response => response.json())
        .then(result => {
            const searchContent = result;
            const searchIndex = lunr(builder => {
                builder.ref("id")
                builder.field("content");
                builder.field("tag");
                builder.field("title");
                builder.field("url");
                builder.field("type");

                Array.from(result).forEach(doc => {
                    builder.add(doc)
                }, builder)
            })
            searchInput.removeAttribute("disabled");
            searchInput.addEventListener("keyup", e => {
                let searchString = e.target.value;
                if (searchString && searchString.length > 2) {
                    try {
                        searchResults = searchIndex.search(searchString);
                    } catch (err) {
                        if (err instanceof lunr.QueryParseError) {
                            return;
                        }
                    }
                } else {
                    searchResults = [];
                }

                if (searchResults.length > 0) {
                    searchResultElement.innerHTML = searchResults.map(match => {
                        let item = searchContent.find(el => {
                            return el.id == parseInt(match.ref);
                        });
                        return "<li>" +
                            "<h4 title='field: title'><a href='" + item.url + "'>" + mark(item.title, searchString) + "</a></h4>" +
                            "<p class='type'>" + item.type + "</p>" +
                            "<p class='summary' title='field: content'>" +
                            mark((item.content.length > 200 ? (item.content.substring(0, 200) + "...") : item.content), searchString) +
                            "</p>" +
                            "<p class='tags' title='field: tag'>" + tags(item.tag, searchString) + "</p>" +
                            "<a href='" + item.url + "' title='field: url'>" + mark(item.url, searchString) + "</a>" +
                            "</li>";
                    }).join("");
                } else {
                    searchResultElement.innerHTML = "<li><p class='no-result'>No results found</p></li>";
                }
            });
        })
        .catch(err => {
            console.error(err);
        });
});
```

There are some functions in there to make a nice transition for open/closing the search. But the important part is

```js
fetch("/search")
    .then(response => response.json())
    .then(result => {
        const searchContent = result;
        const searchIndex = lunr(builder => {
            builder.ref("id")
            builder.field("content");
            builder.field("tag");
            builder.field("title");
            builder.field("url");
            builder.field("type");

            Array.from(result).forEach(doc => {
                builder.add(doc)
            }, builder)
        })
        searchInput.removeAttribute("disabled");
        searchInput.addEventListener("keyup", e => {
            let searchString = e.target.value;
            if (searchString && searchString.length > 2) {
                try {
                    searchResults = searchIndex.search(searchString);
                } catch (err) {
                    if (err instanceof lunr.QueryParseError) {
                        return;
                    }
                }
            } else {
                searchResults = [];
            }

            if (searchResults.length > 0) {
                searchResultElement.innerHTML = searchResults.map(match => {
                    let item = searchContent.find(el => {
                        return el.id == parseInt(match.ref);
                    });
                    return "<li>" +
                        "<h4 title='field: title'><a href='" + item.url + "'>" + mark(item.title, searchString) + "</a></h4>" +
                        "<p class='type'>" + item.type + "</p>" +
                        "<p class='summary' title='field: content'>" +
                        mark((item.content.length > 200 ? (item.content.substring(0, 200) + "...") : item.content), searchString) +
                        "</p>" +
                        "<p class='tags' title='field: tag'>" + tags(item.tag, searchString) + "</p>" +
                        "<a href='" + item.url + "' title='field: url'>" + mark(item.url, searchString) + "</a>" +
                        "</li>";
                }).join("");
            } else {
                searchResultElement.innerHTML = "<li><p class='no-result'>No results found</p></li>";
            }
        });
    })
    .catch(err => {
        console.error(err);
    });
```

This loads the json in a `Promise` from our search url. Then when that is successful it will load the data into `lunr`.

```js
const searchContent = result.data;
const searchIndex = lunr(function () {
   this.ref("id")
   this.field("content");
   this.field("tag");
   this.field("title");
   this.field("url");

   Array.from(result.data).forEach(function (doc) {
      this.add(doc)
   }, this)
})
```

So now `lunr` indexes all the fields we wanted. Here the index from before is used as a reference

```js
this.ref("id")
```

and what other fields to index

```js
this.field("content");
this.field("tag");
this.field("title");
this.field("url");
```

And then finally, load the results into a template, that can be injected into the `ul.search-results` element

```js
if (searchResults.length > 0) {
    searchResultElement.innerHTML = searchResults.map(function (match) {
            let item = searchContent.find(function(e) {
                    return e.id == parseInt(match.ref);
                    });
            return "<li>" +
            "<h4 title='field: title'><a href='" + item.url + "'>" + mark(item.title, searchString) + "</a></h4>" +
            "<p class='summary' title='field: content'>" +
            mark((item.content.length > 200 ? (item.content.substring(0, 200) + "...") : item.content), searchString) +
            "</p>" +
            "<p class='tags' title='field: tag'>" + tags(item.tag, searchString) + "</p>" +
            "<a href='" + item.url + "' title='field: url'>" + mark(item.url, searchString) + "</a>" +
            "</li>";
            }).join("");
} else {
    searchResultElement.innerHTML = "<li><p class='no-result'>No results found</p></li>";
}
```

And all wrapped nicely into the `keypup` event on the search input.

BOOM, all set {{< inline-image "images/100.png"  Fit "24x24">}}. Happy copy-pasting


If you want to use [`Fusejs`](https://fusejs.io/), there's a nice post [here](https://gist.github.com/eddiewebb/735feb48f50f0ddd65ae5606a1cb41ae)
