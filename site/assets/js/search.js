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

