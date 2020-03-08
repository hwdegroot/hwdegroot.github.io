/***************************************************************************/
// Taken from underscore.js
// Returns a function, that, as long as it continues to be invoked, will not
// be triggered. The function will be called after it stops being called for
// N milliseconds. If `immediate` is passed, trigger the function on the
// leading edge, instead of the trailing.
/***************************************************************************/
const throttle = (fn, delay) => {
    let canCall = true
    return (...args) => {
        if (canCall) {
            fn.apply(null, args)
            canCall = false
            setTimeout(() => {
                canCall = true
            }, delay)
        }
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const activeClass = "current";
    const menuItems = Array.from(document.querySelectorAll('#TableOfContents a[href^="#"]'));
    const contentItems = menuItems.map(item => {
        let el = document.querySelector(item.hash);
        let rect = el.getBoundingClientRect();

        return {
            elm: item,
            offset: {
                top: rect.top + window.pageYOffset,
                left: rect.left + window.pageXOffset,
            },
            target: el,
        };
    })

    const activate = target => {
        menuItems.filter(item => {
            return item.classList.contains(activeClass);
        })
            .forEach(item => {
                item.classList.remove(activeClass);
            });

        target.classList.add(activeClass);
        history.pushState(null, null, target.hash);
    }

    const highlightItem = () => {
        let highlight = contentItems.filter(item => {
            return item.offset.top < window.pageYOffset + 15;
        }).pop();
        if (highlight) {
            activate(highlight.elm);
        } else {
            activate(contentItems[0].elm);
        }
    }

    menuItems.forEach(a => {
        a.addEventListener('click', e => {
            e.preventDefault();
            const elm = document.querySelector(e.target.hash);
            if (elm) {
                elm.scrollIntoView({
                    behavior: 'smooth'
                });

                activate(e.target);
            }
        });
    });

    document.addEventListener('scroll', () => {
        throttle(highlightItem, 250)();
    });

    const menuToggle = document.querySelector('.toc-toggle');
    if (menuToggle) {
        menuToggle.addEventListener('click', e => {
            let wrapper = document.querySelector('aside.menu-wrapper');
            if (wrapper.classList.contains('hidden')) {
                wrapper.classList.remove('hidden');
            } else  {
                wrapper.classList.add('hidden');
            }
        });
    }

    if (window.location.hash) {
        const elm = document.querySelector(window.location.hash);
        if (elm) {
            elm.scrollIntoView({
                behavior: 'smooth'
            });

            activate(document.querySelector(`a[href='${window.location.hash}']`));
        }
    } else {
        activate(contentItems[0].elm);
    }
});
