// Permet de detecter l'appui sur une touche
$(document)
	.keydown(function(e) {
		if(!touchePressee) {
			// La touche a été pressée : on met à jour la figure
			touchePressee = true;
			testTouches(e);
		}
	})
	.keyup(function(e) {
		if(touchePressee) {
			// La touche a été relachée : on le mémorise
			touchePressee = false;
		}
	});

	
// Teste si les touches de direction gauche ou droite ont été pressées
function testTouches(e) {
	if(e.keyCode == 37) {
		// La touche de direction gauche a été pressée
		if(t > -1.0) {
			// On n'a pas encore atteint la valeur minimum pour t
			// On met t à jour et on redessine la figure
			t -= 0.01; 
			dessiner();
		}
	} else if (e.keyCode == 39) {
		// La touche de direction droite a été pressée
		if(t < 1.0) {
			// On n'a pas encore atteint la valeur maximum pour t
			// On met t à jour et on redessine la figure
			t += 0.01;
			dessiner();
		}
	}
}

// Donne l'angle d'un vecteur par rapport à l'horizontale
function angleHorizontale(P1,P2) {
	return(Math.atan2(P2.y-P1.y,P2.x-P1.x));
}
	
// Calcule le déterminant des vecteurs AB et AC
function determinant(A,B,C) {
	return((B.x - A.x) * (C.y - A.y) - (B.y - A.y) * (C.x - A.x));
}
	
// Calcule la longueur d'un segment
function longueur(P1,P2) {
	return(Math.sqrt((P2.x-P1.x)**2 + (P2.y-P1.y)**2));
}

// Permet de dessiner la figure, en fonction du paramètre t
function dessiner(){		
	// On calcule les coordonnées des points
	const C = {x: Math.sign(t)*(B.y-A.y)*Math.sqrt(Math.abs(t)*(1-Math.abs(t)))+Math.abs(t)*(B.x-A.x)+A.x,y: Math.sign(t)*(A.x-B.x)*Math.sqrt(Math.abs(t)*(1-Math.abs(t)))+Math.abs(t)*(B.y-A.y)+A.y};	
	const J = {x: (A.x + C.x)/2,y:(A.y + C.y)/2}; // J est le milieu de [AC]
	const K = {x: (B.x + C.x)/2,y: (B.y + C.y)/2}; // K est le milieu de [BC]
		
	// Puis les longueurs de [AC] et [BC]
	const b = longueur(A,C);
	const a = longueur(B,C);
		
	// On détermine ensuite les angles qui nous seront utiles pour le dessin des lunules
	const alpha = angleHorizontale(C,A);
	const beta = angleHorizontale(C,B);
	const gamma = angleHorizontale(I,C);
	const delta = angleHorizontale(I,B);
	const epsilon = angleHorizontale(I,A);
		
	// Il nous reste à trouver le déterminant des vecteurs AB et AC
	const det = determinant(A,B,C);
		
	// Avant de dessiner, il faut effacer l'ancienne figure
	ctx.clearRect(0,0,canvas.width,canvas.height)

	// On dessine le triangle ABC
	ctx.beginPath();
	ctx.moveTo(A.x, A.y);
	ctx.lineTo(B.x, B.y);
	ctx.lineTo(C.x, C.y);
	ctx.closePath();
	ctx.fillStyle = "orange";
	ctx.fill();

	// On dessine les points des trois sommets du triangle
	ctx.beginPath();
	ctx.arc(A.x, A.y, 3, 0, Math.PI * 2);
	ctx.closePath();
	ctx.fill();
	ctx.beginPath();
	ctx.arc(B.x, B.y, 3, 0, Math.PI * 2);
	ctx.closePath();
	ctx.fill();
	ctx.beginPath();
	ctx.arc(C.x, C.y, 3, 0, Math.PI * 2);
	ctx.closePath();
	ctx.fill();

	// On rajoute les noms des points
	ctx.font = '16px Arial';
	ctx.fillText("A", A.x - 15, A.y + 15);
	ctx.fillText("B", B.x + 5, B.y + 15);
	ctx.fillText("C", C.x - 10, C.y - 10);

	// Première lunule
	ctx.fillStyle = "blue";
	ctx.beginPath();
	ctx.arc(J.x,J.y,b/2,alpha,alpha+Math.PI,det > 0?true:false); // l'arc part du point A pour arriver au point C
	ctx.arc(I.x,I.y,c/2,gamma,epsilon,det > 0?false:true); // l'arc part du point C pour arriver au point A
	ctx.closePath();
	ctx.fill();
		
	// Seconde lunule
	ctx.beginPath();
	ctx.arc(K.x,K.y,a/2,beta,beta + Math.PI,det > 0?false:true); // l'arc part du point B pour arriver au point C
	ctx.arc(I.x,I.y,c/2,gamma,delta,det > 0?true:false); // l'arc part du point C pour arriver au point B
	ctx.closePath();
	ctx.fill();
}
			
// Définition des constantes
const A = {x: 50,y: 100};
const B = {x: 200,y: 150};
// Milieu de [AB]
const I = {x: (A.x + B.x)/2,y: (A.y + B.y)/2};
// Longueur de [AB]
const c = longueur(A,B);
	
const canvas = document.getElementById('canvas'); // le canvas où dessiner
const ctx = canvas.getContext('2d'); // le contexte du canvas
	
// Définition des variables
let touchePressee = false;
let t = 0.5; // Pour déterminer la position du point C
		
dessiner();