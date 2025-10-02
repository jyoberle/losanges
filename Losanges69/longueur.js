// Calcule la longueur d'un segment
function longueur(P1,P2) {
	return(Math.sqrt((P2.x-P1.x)**2 + (P2.y-P1.y)**2));
}
	
// Définition des points
const A = {x: 50,y: 100};
const B = {x: 200,y: 150};

// Calcule et affiche la longueur du segment [AB]
console.log(longueur(A,B));