#!/bin/bash

HUGO_VERSION="$1"

AVAILABLE_VERSIONS=$(curl -s https://api.github.com/repos/gohugoio/hugo/git/refs/tags | jq '[.[].ref | split("/")[-1] | sub("v";"")]')

if [[ "$1" == "latest" ]]; then
    HUGO_VERSION=$(echo $AVAILABLE_VERSIONS | jq -r '.[-1]')
elif [[ $# -eq 0 ]] || ! [[ $HUGO_VERSION =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
    echo "Invalid version $HUGO_VERSION"
    exit 1;
fi

AVAILABLE=$(echo $AVAILABLE_VERSIONS | jq --arg version "$HUGO_VERSION" '. as $v | $version | IN($v[])')

if [[ "$AVAILABLE" == "true" ]]; then
    echo $HUGO_VERSION > .hugo-version
    exit 0
fi

cat <<- VERSIONS
Can not find version $HUGO_VERSION in available version:

...
$(echo $AVAILABLE_VERSIONS | jq -r '.[]' | tail -10 )
VERSIONS

exit 1

