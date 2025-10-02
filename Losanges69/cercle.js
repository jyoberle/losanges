// Dessine un cercle
const canvas = document.getElementById('canvas'); // le canevas où dessiner
const ctx = canvas.getContext('2d'); // le contexte du canevas
const A = {x: canvas.width/2,y: canvas.height/2}; // le point A, au centre du canevas 
ctx.clearRect(0,0,canvas.width,canvas.height); // effacement du canevas
ctx.fillStyle = "blue"; // couleur de remplissage
ctx.beginPath(); // début du chemin
ctx.arc(A.x,A.y,canvas.width/2,0,2*Math.PI); // cercle centré en A
ctx.closePath(); // fin du chemin
ctx.fill(); // remplissage du cercle