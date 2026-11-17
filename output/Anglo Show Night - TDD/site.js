const printButton = document.querySelector("#print");
printButton.hidden = false;
printButton.addEventListener("click", () => window.print());
