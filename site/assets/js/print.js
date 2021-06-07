document.addEventListener("DOMContentLoaded", () => {
    let location = window.location.search;
    console.log(location);
    if (location && location.length > 1) {
        let search = location.substr('1')
            .split("&")
            .map(q => q.split("="))
            .reduce((a, c) => {
                a[c[0]] = c[1];
                return a;},
                {}
            );

        if (search.hasOwnProperty("print")) {
            document.body.classList.add("print");
        }
    }
});
