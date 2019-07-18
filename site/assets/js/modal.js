document.addEventListener("DOMContentLoaded", () => {
    // Get the modal
    const modals = document.querySelectorAll(".modal");

    if(modals) {
        modals.forEach(modal => {
            let imageId = modal.getAttribute("data-target");
            if (imageId) {
                let figure = document.getElementById(imageId);
                let close = document.getElementById(`close-${imageId}`);
                figure.addEventListener("click", () => {
                    show(modal);

                    close.addEventListener("click", () => {
                        hide(modals);
                    });
                });
            }

            // When the user clicks anywhere outside of the modal, close it
            window.addEventListener("click", event => {
                if (event.target == modal) {
                    hide(modals);
                }
            });
        });
    }

    const hide = modals => {
        modals.forEach(modal => {
            modal.classList.remove("active");
        });
        document.body.style.overflow = "initial";
    }

    const show = modal => {
        modal.classList.add("active");
        document.body.style.overflow = "hidden";
    }

});
