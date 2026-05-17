// Point d'entrée de notre programme
$(document).ready(function() {
	redimCanevas($(document).width(),$.mobile.getScreenHeight()); // dimensionnement (fixe) de la page
	initGraphe(); // initialisation du graphique

	// On obtient le paramètre (l'expression de la fonction)
	var params = {};

	if (location.search) {
		var parts = location.search.substring(1).split('&');

		for (var i = 0; i < parts.length; i++) {
			var nv = parts[i].split('=');
			if (!nv[0]) continue;
			params[nv[0]] = nv[1] || true;
		}
	}

	// On vérifie qu'un paramètre a bien été transmis
	if(typeof(params.fonction) !== "undefined") {
		// On affiche le graphe de la fonction, en éliminant auparavant les guillements et apostrophes du paramètre
		clic(decodeURIComponent(params.fonction).replace(/['"]/g,''),"");
	}	
});

// Redimensionne le canevas après un redimensionnement par l'utilisateur
function redimCanevas(largeur,hauteur) {
	document.getElementById('monCanevas').width = largeur;
	document.getElementById('monCanevas').height = hauteur;
}

// Appelée après un clic sur le bouton Abracadabra !
function clic(formule) {
	// On enlève les éventuels espaces de la fonction
	var chaine = formule.split(' ').join('');

	// On crée dynamiquement une fonction JavaScript
	var fonction = convertitFonctions(chaine);

	// On dessine le graphe à l'aide de la fonction JavaScript
	monGraphe.nouvelleFonction(fonction,-11,11);
}

// Transforme la fonction rentrée par l'utilisateur (sous la forme d'une chaîne) en fonction JavaScript
function convertitFonctions(chaine) {
	var chaine = convertitFonctionsEnChaines(chaine);
	return(new Function("x","{return " + chaine + "}"));
}

// Convertit la fonction rentrée par l'utilisateur (sous la forme d'une chaîne) en chaine au format JavaScript
// Par exemple, cos devient Math.cos
function convertitFonctionsEnChaines(str) {
	// Liste des fonctions susceptibles d'être rentrées par l'utilisateur
	var tableauFonctions = new Array("ln","exp","sqrt","asin","acos","atan","sinh","cosh","tanh","sin","cos","tan","abs","pow");
	// Liste intermédiaire pour la transformation
	var tableauConversions1 = new Array("z1","z2","z3","z4","z5","z6","z7","z8","z9","za","zb","zc","zd","ze");
	// Liste des fonctions au format JavaScript
	var tableauConversions2 = new Array("Math.log","Math.exp","Math.sqrt","Math.asin","Math.acos","Math.atan","Math.sinh","Math.cosh","Math.tanh","Math.sin","Math.cos","Math.tan","Math.abs","Math.pow");
 
	// Pour la fonction puissance (^), on a recours aux fonctions de math.js
	var noeud = math.parse(str); // transformation de l'expression en un arbre de noeuds

	// On recherche toutes les fonctions puissance pour transformer par exemple x^2 en pow(x,2)
	var transformee = noeud.transform(function (noeud, chemin, parent) {
		if (noeud.type == 'OperatorNode' && noeud.op == '^') {
			// On a trouvé un noeud puissance : on mémorise ses arguments (x et 2) dans un tableau
			var argumentsPuissance = [];

			noeud.forEach(function (noeud, chemin, parent) {
				argumentsPuissance.push(noeud);
			});

			// On renvoie un nouveau noeud de la forme pow(x,2)
			return(new math.expression.node.FunctionNode(new math.expression.node.SymbolNode('pow'),argumentsPuissance));
		} else {
			// Si le noeud n'est pas une puissance, on le renvoie sans y toucher
			return noeud;
		}
	});

	// On retransforme l'arbre de noeuds en chaine
	var str = math.string(transformee);

	// On finit en transformant les autres fonctions par substitutions (par exemple ln(x) deviendra Math.log(x))
	for(i = 0;i < tableauFonctions.length;i++) {
		str = str.replaceAll(tableauFonctions[i],tableauConversions1[i]);
	}

	for(i = 0;i < tableauConversions1.length;i++) {
		str = str.replaceAll(tableauConversions1[i],tableauConversions2[i]);
	}

	return(str);
}

// ==== Fonctions pour le tracé basées sur Graphe ====

var monGraphe; // objet JavaScript représentant le graphe (dont le constructeur est Graphe)

// Constructeur de Graphe : il initialise le graphe à partir des informations de configuration
// this permet de créer des variables spécifiques à Graphe et de les partager avec toutes les méthodes de Graphe
function Graphe(config) {
	// Propriétés de l'objet JavaScript
	this.canevas = document.getElementById(config.canvasId);
	this.uniteXParGraduation = config.uniteXParGraduation; // unité en X (au début 1 puis 0,1 en cas de zoom avant, etc.)
	this.uniteYParGraduation = config.uniteYParGraduation; // unité en Y
	this.initMinX = config.minX; // valeur minimale pour X (intialement -11)
	this.initMaxX = config.maxX; // valeur maximale pour X (intialement 11)
	this.equation = config.equation;
	this.couleur = config.couleur;
	this.epaisseur = config.epaisseur;
	this.largeurCanevas = config.largeur;
	this.hauteurCanevas = config.hauteur;
	var plageY = (this.initMaxX - this.initMinX) * this.hauteurCanevas/this.largeurCanevas;
	this.initMinY = -plageY/2;
	this.initMaxY = plageY/2;		
	this.minX = this.initMinX;
	this.maxX = this.initMaxX;
	this.minY = this.initMinY;
	this.maxY = this.initMaxY;
	this.glissement = false; // sera mis à true lorsque l'utilisateur fera glisser le graphe

	// Constantes
	this.couleurAxes = '#aaa';
	this.fonte = '8pt Calibri';
	this.tailleGraduation = 6;

	// Mémorisation du contexte
	this.contexte = this.canevas.getContext('2d');
	// Calcul des valeurs pour le dessin du graphe par défaut
	this.calculValeursPourDessin(1,1,0,0);

	// Dessin des axes
	this.dessinerAbscisses();
	this.dessinerOrdonnees();
	// Dessin du graphe
	this.dessinerGraphe();
}

// On définit plusieurs méthodes propres à Graphe
// La première méthode formate un nombre pour une graduation (par exemple 0.5 ou 6e3)
Graphe.prototype.obtientValeurUnite = function(unite) {
	var chiffresSignificatifs = Math.abs(Math.floor(Math.log10(Math.abs(unite))));
	return((Math.abs(unite) > 1000 || Math.abs(unite) < 0.001)?parseFloat(unite.toPrecision(chiffresSignificatifs+3)).toExponential():parseFloat(unite.toPrecision(chiffresSignificatifs+3)));
}

// Méthode pour dessiner l'axe des abscisses, y compris les graduations
Graphe.prototype.dessinerAbscisses = function() {
	// On dessine l'axe
	var contexte = this.contexte;
	contexte.save();
	contexte.beginPath();
	contexte.moveTo(0, this.centreY);
	contexte.lineTo(this.largeurCanevas, this.centreY);
	contexte.strokeStyle = this.couleurAxes;
	contexte.lineWidth = 2;
	contexte.stroke();

	// On dessine les graduations
	var xPosIncrement = this.uniteXParGraduation * this.uniteX;
	var xPos, unite;
	contexte.fonte = this.fonte;
	contexte.textAlign = 'center';
	contexte.textBaseline = 'top';

	// On commence par les graduations négatives
	xPos = this.centreX - xPosIncrement;
	unite = -1 * this.uniteXParGraduation;
	while(xPos > 0) {
		contexte.moveTo(xPos, this.centreY - this.tailleGraduation / 2);
		contexte.lineTo(xPos, this.centreY + this.tailleGraduation / 2);
		contexte.stroke();
		contexte.fillText(this.obtientValeurUnite(unite), xPos, this.centreY + this.tailleGraduation / 2 + 3);
		unite -= this.uniteXParGraduation;
		xPos = Math.round(xPos - xPosIncrement);
	}

	// Puis on continue avec les graduations positives
	xPos = this.centreX + xPosIncrement;
	unite = this.uniteXParGraduation;
	while(xPos < this.largeurCanevas) {
		contexte.moveTo(xPos, this.centreY - this.tailleGraduation / 2);
		contexte.lineTo(xPos, this.centreY + this.tailleGraduation / 2);
		contexte.stroke();
		contexte.fillText(this.obtientValeurUnite(unite), xPos, this.centreY + this.tailleGraduation / 2 + 3);
		unite += this.uniteXParGraduation;
		xPos = Math.round(xPos + xPosIncrement);
	}
	contexte.restore();
};

// Méthode pour dessiner l'axe des ordonnées, y compris les graduations
Graphe.prototype.dessinerOrdonnees = function() {
	// On dessine l'axe
	var contexte = this.contexte;
	contexte.save();
	contexte.beginPath();
	contexte.moveTo(this.centreX, 0);
	contexte.lineTo(this.centreX, this.hauteurCanevas);
	contexte.strokeStyle = this.couleurAxes;
	contexte.lineWidth = 2;
	contexte.stroke();

	// On dessine les graduations
	var yPosIncrement = this.uniteYParGraduation * this.uniteY;
	var yPos, unite;
	contexte.fonte = this.fonte;
	contexte.textAlign = 'right';
	contexte.textBaseline = 'middle';

	// On commence par les graduations positives
	yPos = this.centreY - yPosIncrement;
	unite = this.uniteYParGraduation;
	while(yPos > 0) {
		contexte.moveTo(this.centreX - this.tailleGraduation / 2, yPos);
		contexte.lineTo(this.centreX + this.tailleGraduation / 2, yPos);
		contexte.stroke();
		contexte.fillText(this.obtientValeurUnite(unite), this.centreX - this.tailleGraduation / 2 - 3, yPos);
		unite += this.uniteYParGraduation;
		yPos = Math.round(yPos - yPosIncrement);
	}

	// Puis on continue avec les graduations négatives
	yPos = this.centreY + yPosIncrement;
	unite = -1 * this.uniteYParGraduation;
	while(yPos < this.hauteurCanevas) {
		contexte.moveTo(this.centreX - this.tailleGraduation / 2, yPos);
		contexte.lineTo(this.centreX + this.tailleGraduation / 2, yPos);
		contexte.stroke();
		contexte.fillText(this.obtientValeurUnite(unite), this.centreX - this.tailleGraduation / 2 - 3, yPos);
		unite -= this.uniteYParGraduation;
		yPos = Math.round(yPos + yPosIncrement);
	}
	contexte.restore();
};

// Méthode pour dessiner le graphe de la fonction
Graphe.prototype.dessinerGraphe = function() {
	// On récupère le contexte du canevas
	var contexte = this.contexte;
	// On modifie ce contexte pour le centrer dans le canevas, et auparavant on le sauvegarde
	contexte.save();
	this.centreContexte();

	// On dessine le graphe en reliant ses points dans une boucle
	contexte.beginPath();
	contexte.moveTo(this.minX, this.equation(this.minX));
	var ancienNaN = 0;

	for(var x = this.minX + this.iteration; x <= this.maxX; x += this.iteration) {
		// Si la fonction n'est pas définie en ce point, on l'ignore
		if(isNaN(this.equation(x))) {
			ancienNaN = 1;
			continue;
		} else {
			if(ancienNaN == 1) {
				contexte.moveTo(x,this.equation(x));
			}
			
			ancienNaN = 0;
		}

		contexte.lineTo(x,this.equation(x));
	}

	// On restaure le contexte
	contexte.restore();
	// Puis on trace effectivement le graphe
	contexte.lineJoin = 'round';
	contexte.lineWidth = this.epaisseur;
	contexte.strokeStyle = this.couleur;
	contexte.stroke();
};

// Méthode modifiant le contexte pour le centrer dans le cavenas
Graphe.prototype.centreContexte = function() {
	var contexte = this.contexte;

	// Contexte au centre du canevas
	this.contexte.translate(this.centreX, this.centreY);

	// L'échelle des ordonnées est inversée car l'origine "informatique" du plan se situe dans le coin supérieur gauche du canevas
	// c'est-à-dire que sans cette modification, les ordonnées s'accroissent en descendant
	contexte.scale(this.echelleX, -this.echelleY);
};

// Méthode pour calculer différentes valeurs pour le dessin du graphe (nombre de graduations, étendues, etc.)
Graphe.prototype.calculValeursPourDessin = function(echelleX,echelleY,deltaX,deltaY) {
	var delta = this.maxX - this.minX;
	this.minX = (this.minX - deltaX*delta/this.largeurCanevas)*echelleX;
	this.minY = (this.minY - deltaY*delta/this.hauteurCanevas)*echelleY;
	this.maxX = (this.maxX - deltaX*delta/this.largeurCanevas)*echelleX;
	this.maxY = (this.maxY - deltaY*delta/this.hauteurCanevas)*echelleY;
		
	// On ne montre pas plus de 10 graduations
	var etendueX = this.maxX - this.minX;
	this.uniteXParGraduation = Math.pow(10,Math.floor(Math.log10(etendueX/2)));
	var etendueY = this.maxY - this.minY;
	this.uniteYParGraduation = Math.pow(10,Math.floor(Math.log10(etendueY/2)));
		
	this.etendueX = (this.maxX - this.minX);
	this.etendueY = (this.maxY - this.minY);
	this.uniteX = this.largeurCanevas / this.etendueX;
	this.uniteY = this.hauteurCanevas / this.etendueY;
	this.centreX = Math.round((-this.minX / this.etendueX) * this.largeurCanevas);
	this.centreY = Math.round((-this.minY / this.etendueY) * this.hauteurCanevas);
	this.iteration = (this.maxX - this.minX) / 1000;
	this.echelleX = this.largeurCanevas / this.etendueX;
	this.echelleY = this.hauteurCanevas / this.etendueY;
}

// Méthode pour redessiner le graphe, y compris les axes et les graduations
Graphe.prototype.redessiner = function() {
	this.contexte.clearRect(0, 0, this.largeurCanevas, this.hauteurCanevas);
	this.dessinerAbscisses();
	this.dessinerOrdonnees();
	this.dessinerGraphe();
}

// Méthode pour effectuer un reset du graphe, lorsque l'utilisateur clique sur le bouton droit de la souris et entre une nouvelle fonction
Graphe.prototype.reset = function() {
	this.minX = this.initMinX;
	this.minY = this.initMinY;
	this.maxX = this.initMaxX;
	this.maxY = this.initMaxY;
	this.calculValeursPourDessin(1,1,0,0);
	this.redessiner();
}

// Méthode pour zoomer ou dézoomer le graphe lorsque l'utilisateur manipule la molette de la souris
Graphe.prototype.moletteSouris = function(delta) {
	if(delta < 1) {
		this.calculValeursPourDessin(1.01,1.01,0,0);
	} else {
		this.calculValeursPourDessin(0.99,0.99,0,0);
	}

	this.redessiner();
};
		
// Méthode appelée lorsque l'utilisateur clique sur le bouton gauche de sa souris
Graphe.prototype.boutonSourisPresse = function(x,y) {
	// On mémorise les coordonnées du clic relativement au canevas
	var rectangleCanevas = this.canevas.getBoundingClientRect();
	this.sourisX = x - rectangleCanevas.left;
	this.sourisY = y - rectangleCanevas.top;
	// On mémorise le fait que l'utilisateur va déplacer le graphe
	this.glissement = true;
}

// Méthode appelée lorsque l'utilisateur relâche le bouton gauche de la souris
Graphe.prototype.boutonSourisRelache = function() {
	// On mémorise le fait qu'il n'y a plus lieu de déplacer le graphe avec la souris
	this.glissement = false;
}

// Méthode appelée lorsque l'utilisateur déplace la souris
Graphe.prototype.mouvementSouris = function(x,y) {
	if(this.glissement) {
		// On détermine les coordonnées de la souris relativement au canevas
		var rectangleCanevas = this.canevas.getBoundingClientRect();
		var sourisX = x - rectangleCanevas.left;
		var sourisY = y - rectangleCanevas.top;
		// On effectue les calculs en considérant la différence entre les coordonnées actuelles de la souris et les précédentes
		this.calculValeursPourDessin(1,1,sourisX - this.sourisX,sourisY - this.sourisY);
		// On met à jour le graphe
		this.redessiner();
		// On mémorise les nouvelles coordonnées de la souris
		this.sourisX = sourisX;
		this.sourisY = sourisY;
	}
}

// Méthode appelée lorsqu'une nouvelle fonction est validée par l'utilisateur
Graphe.prototype.nouvelleFonction = function(fonction,min,max) {
	this.equation = fonction;
	this.initMinX = min;
	this.initMaxX = max;
	monGraphe.reset();
}

Graphe.prototype.changementOrientation = function(orientation) {
	redimCanevas($.mobile.getScreenHeight(),$(document).width());
	var monCanevas = document.getElementById("monCanevas");
	this.largeurCanevas = monCanevas.width;
	this.hauteurCanevas = monCanevas.height;
	this.calculValeursPourDessin(1,1,0,0);
	this.redessiner();
}

// ==== Fin des fonctions pour le tracé ====

// Fonction appelée lorsque l'utilisateur manipule la molette de la souris
function ecouteurMoletteSouris(delta) {
	monGraphe.moletteSouris(delta);
}

// Fonction appelée lorsque l'utilisateur presse l'un des boutons de la souris (gauche ou droit)
function ecouteurSourisBoutonPresse(x,y) {
	monGraphe.boutonSourisPresse(x,y)
}

// Fonction appelée lorsque l'utilisateur relâche le bouton de la souris
function ecouteurSourisBoutonRelache(e) {
	monGraphe.boutonSourisRelache()
}

// Fonction appelée lorsque la souris bouge (et que son bouton gauche est pressé par l'utilisateur)
function ecouteurDeplacementSouris(x,y) {
	monGraphe.mouvementSouris(x,y)
}

function ecouteurChangementOrientation(event) {
	monGraphe.changementOrientation();
}

function ecouteurDoubleTapotement() {
	monGraphe.reset();
}

// Initialisation du graphique 
function initGraphe() {
	var monCanevas = document.getElementById("monCanevas");

	// On crée l'objet Graphe avec des valeurs par défaut
	monGraphe = new Graphe({
		canvasId: 'monCanevas', // identifiant du canevas
		minX: -11.0, // valeur minimale du tracé de la fonction 
		maxX: 11.0, // valeur maximale
		uniteXParGraduation: 1.0,  // informations pour les graduations
		uniteYParGraduation: 1.0,
		equation: function(x) {return x}, // fonction par défaut : f(x) = x
		couleur: 'green', // couleur du tracé
		epaisseur:1, // épaisseur du tracé
		largeur:monCanevas.width, // largeur de l'écran
		hauteur:monCanevas.height // hauteur de l'écran
	});
	
	// On crée une instance de hammer qui nous permettra de mettre en place les écouteurs pour les actions de l'utilisateur
	var hammer = new Hammer(monCanevas);
	// On configure les touchers de l'utilisateur sur l'écran dans toutes les directions
	hammer.get('pan').set({ direction: Hammer.DIRECTION_ALL });
	hammer.on('panstart',function(ev) {
		// Appelée lorsque l'utilisateur pose le doigt sur l'écran
		ecouteurSourisBoutonPresse(ev.srcEvent.offsetX,ev.srcEvent.offsetY);
	});
	hammer.on('panend',function(ev) {
		// Appelée lorsque l'utilisateur relève le doigt
		ecouteurSourisBoutonRelache()
	});
	hammer.on('panmove',function(ev) {
		// Appelée lorsque l'utilisateur déplace son doigt sur l'écran
		ecouteurDeplacementSouris(ev.srcEvent.offsetX,ev.srcEvent.offsetY);
	});
	// On active le suivi du pincer
	hammer.get('pinch').set({ enable: true });
	hammer.on("pinch", function (ev) {
		// Appelée lorsque l'utilisateur zoome ou dézoome
		ecouteurMoletteSouris(ev.scale);
	});
	hammer.on('doubletap',function (ev) {
		// Appelée lorsque l'utilisateur effectue un double tapotement
		ecouteurDoubleTapotement();
	});
	$(window).on("orientationchange",function(ev){
		// Appelée lorsque l'utilisateur tourne le téléphone
		// L'appel se fait après une attente de 200 ms, le temps que l'écran se redessine
		setTimeout(function(){
			ecouteurChangementOrientation(ev);
		},200);
	});
}