---
title: "What about tailwindcss?! I'm hooked!"
date: 2022-02-17T07:39:17Z
type: post
tags:
    - development
    - tailwindcss
    - python
    - flask
    - sqlalchemy
    - lang-en
images:
    - images/og/cover.png
disqus_identifier: "d20caec3b48a1eef164cb4ca81ba2587"
disqus_title: "what-about-tailwindcss-i-am-hooked"
showComments: true

---

Recently I started working on an app to share secrets with other people in a safe way.
I have seen and used apps like these before, like [secrets.mendix.com](https://secrets.mendix.com).
However I wanted to get started with python flask. So I used this as an excuse to do so.

Python uses a nice library, [`cryptography`](https://pypi.org/project/cryptography/) that supports two-way
encryption using a key.

So I googled my ass off, like anyone would do. I am more familiar with PHP and Laravel. I love the
principle of managing the db using migrations, so I figured there would be something similar for
python flask as well. And guess what. There is! It is [SQLAlchemy](https://docs.sqlalchemy.org/en/14/),
which uses [albemic](https://alembic.sqlalchemy.org/en/latest/index.html) under the hood. This supports
exactly what I want.

It did not take too much effort to get this started. I did struggle a bit with creating and running the
migrations. But after a while, I figured out that I needed to create the versions first, using the
`revision` command.

```sh
flask db revision -m "My version"
```

When I finally figured that out, I was good to go.
Just run a migration script on deployment, and profit!

```sh
# wsgi_app/migrations/migrate.sh

echo "===== Initalize the database ====="
# avoid annoying error after first migration
if ! [[ -d wsgi_app/migrations ]]; then
    flask db init
else
    echo "DB already initialized. Skipping"
fi

echo "===== Run the migrations ====="
flask db migrate

echo "===== Upgrade the database ====="
flask db upgrade

```

So now I have an app, but it looks terrible. How to fix this...
I had heard about [tailwindcss](https://tailwindcss.com/docs/installation). So I thought, maybe I can make it
easy on myself, and see if I can use that. And boy, was I not disappointed.

First I needed to integrate tailwind into my application. Unfortunately I had to fallback to npm,
but that was a small price to pay.

I found a [tutorial online](https://www.section.io/engineering-education/integrate-tailwindcss-into-flask/) on
how to implement tailwind in a flask project.

I just followed the tutorial, and it worked. I did notice that compiling the tailwind css, it does some magic
below the hood where it checks, the files indicated in your tailwind configuration, for used classes. Only those
classes are included in the generated file.

To do that, add the `content` section in your tailwind config.

```js
// tailwind.config.js
module.exports = {
    darkMode: 'class',
    content: [
        './wsgi_app/templates/**/*.{html,js,svg}',
    ],
}
```

To solve that, just make sure that every time that a new class is added in one of the templates, that the tailwind css'es
are regenerated. Locally, I fixed this by running an `npm` container with nodemon, watching changes in all my templates.

I have the following section defined in the `package.json`

```json
{
    ...
    "scripts": {
        "compile": "npx tailwindcss -i wsgi_app/static/src/main.tailwind -o wsgi_app/static/css/main.css",
        "prewatch": "npm install",
        "watch": "nodemon --watch wsgi_app/static/src --watch wsgi_app/templates --exec 'npm run compile'",
        "build": "npm run compile"
    },
    ...
}
```

Now, every time I change a template, the css file is automatically regenerated. 💖

Happy secret sharing!!

You can find the project in [gitlab](https://gitlab.com/hwdegroot/secret-sharing) and an example app
on [heroku](https://share-secret-safely.herokuapp.com/). And guess what, it has an API 😍


