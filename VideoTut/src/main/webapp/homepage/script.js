for (let i = 0; i < 18; i++) {
    let b = document.createElement("div");
    b.className = "bubble";
    let size = Math.random() * 28 + 8;
    b.style.width = b.style.height = size + "px";
    b.style.left = Math.random() * 100 + "%";
    b.style.animationDuration = Math.random() * 7 + 8 + "s";
    b.style.animationDelay = Math.random() * 6 + "s";
    document.body.appendChild(b);
}
