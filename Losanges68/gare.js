// Valeurs des tokens
let X_ID = 0;
let SIN_ID = 1;
let EXP_ID = 2;
let PAR_OUVRANTE_ID = 3;
let PAR_FERMANTE_ID = 4;
let PLUS_ID = 5;
let MOINS_ID = 6;
let MULT_ID = 7;
let DIV_ID = 8;
let PUISSANCE_ID = 9;
let PLUS_UNAIRE_ID = 10;
let MOINS_UNAIRE_ID = 11;
let NOMBRE_ID = 12;

// Constantes pour l'associativité
let GAUCHE = 0;
let DROITE = 1;
let NA = 2;

let ListeExpregToken = ['^(x)','^(sin)','^(exp)','^(\\()','^(\\))','^(\\+)','^(-)','^(\\*)','^(/)','^(\\^)','^(\\+)','^(-)','^(\\d+(?:\\.\\d+)?(?:E-?\\d+)?)'];
// Liste des tokens sous forme de texte
let listeChaineToken = ['x','sin','e','(',')','+','-','&InvisibleTimes;','/','^','+','-','0'];

// Priorités pour l'algorithme de la gare de triage
var Priorites = new Object();
Priorites[PLUS_ID] = 5;
Priorites[MOINS_ID] = 5;
Priorites[MULT_ID] = 10;
Priorites[DIV_ID] = 10;
Priorites[PLUS_UNAIRE_ID] = 15;
Priorites[MOINS_UNAIRE_ID] = 15;
Priorites[PUISSANCE_ID] = 20;

// Associativités pour l'algorithme de la gare de triage
var Associativites = new Object();
Associativites[PLUS_ID] = GAUCHE;
Associativites[MOINS_ID] = GAUCHE;
Associativites[MULT_ID] = GAUCHE;
Associativites[DIV_ID] = GAUCHE;
Associativites[PUISSANCE_ID] = DROITE;
Associativites[PLUS_UNAIRE_ID] = NA;
Associativites[MOINS_UNAIRE_ID] = NA;

// Liste où seront stockés les tokens de la chaine rentrée par l'utilisateur
var listeTokens;
// Liste où seront stockés les nombres de la chaine rentrée par l'utilisateur
var listeNombres;

// Déclaration de la pile de sortie et de celle des opérateurs
var pileSortie;
var pileOperateurs;

// Extrait des tokens de la chaine rentrée par l'utilisateur
function obtientListeTokens(expr)
{
	var index = 0;
  
	listeTokens = [];
	listeNombres = [];
  
	expr = expr.replace(/ /g,'') // on enlève le retour chariot et tous les espaces
  
	while(index !== -1 && index < expr.length) {
		// On regarde s'il s'agit d'un signe plus
		var re = new RegExp(ListeExpregToken[PLUS_ID]);
		var match = expr.at(index).match(re);
      
		if(match && match[0].length !== 0) {
			// On regarde s'il est en position 0 ou s'il est précédé d'une parenthèse ouvrante
			if(index == 0 || expr.at(index - 1) === '(') {
				listeTokens.push(PLUS_UNAIRE_ID); // il s'agit d'un opérateur unaire
			} else {
				listeTokens.push(PLUS_ID); // il s'agit d'un opérateur binaire
			}
	  
			index += match[0].length;
			continue; // on a trouvé un token
		}
	
		// On regarde s'il s'agit d'un signe moins
		var re = new RegExp(ListeExpregToken[MOINS_ID]);
		var match = expr.at(index).match(re);
      
		if(match && match[0].length !== 0) {
			// On regarde s'il est en position 0 ou s'il est précédé d'une parenthèse ouvrante
			if(index == 0 || expr.at(index - 1) === '(') {
				listeTokens.push(MOINS_UNAIRE_ID); // il s'agit d'un opérateur unaire
			} else {
				listeTokens.push(MOINS_ID); // il s'agit d'un opérateur binaire
			}
	  
			index += match[0].length;
			continue; // on a trouvé un token
		}

		// On cherche un autre token qu'un signe plus ou moins
		var tokenFound = false;

		for(var i=0;i < ListeExpregToken.length;i++) {
			var re = new RegExp(ListeExpregToken.at(i));
			var match = expr.substring(index).match(re);
      
			if(match && match[0].length !== 0) {
				tokenFound = true;
				index += match[0].length;

				if(i === NOMBRE_ID) {
					listeTokens.push(i + listeNombres.length);
					listeNombres.push(match[0]); // les nombres sont stockés dans une liste séparée
				} else {
					listeTokens.push(i);
				}

				break; // on a trouvé un token
			}
		}

		if(tokenFound === false) {
			// On n'a pas trouvé de token
			listeTokens = [];
			break;
		}
	}
}

// Indique si un token est une fonction
function estUneFonction(token)
{
	switch(token) {
		case SIN_ID:
		case EXP_ID:
			return(true);

		default:
		return(false);
	}
}

// Indique si un token est un opérateur
function estUnOperateur(token) {
	switch (token) {
		case PLUS_ID:
		case MOINS_ID:
		case MULT_ID:
		case DIV_ID:
		case PUISSANCE_ID:
		case PLUS_UNAIRE_ID:
		case MOINS_UNAIRE_ID:
			return(true);

		default:
			return(false);
	}
}

// Applique l'algorithme de la gare de triage sur la liste de tokens
function gareDeTriage()
{
	pileSortie = [];
	pileOperateurs = [];
	
	for(var i=0;i < listeTokens.length;i++) {
		var token = listeTokens.at(i);

		switch(token) {
			case X_ID:
			pileSortie.push(token);
			break;

		case SIN_ID:
		case EXP_ID:
			pileOperateurs.push(token);
			break;

		case PAR_OUVRANTE_ID:
			pileOperateurs.push(PAR_OUVRANTE_ID);
			break;

		case PAR_FERMANTE_ID:
			while(pileOperateurs.length !== 0 && pileOperateurs.at(-1) !== PAR_OUVRANTE_ID) {
				pileSortie.push(pileOperateurs.pop());
			}

			if(pileOperateurs.length === 0) {
				return(false);
			}

			if(pileOperateurs.at(-1) !== PAR_OUVRANTE_ID) {
				return(false);
			}

			pileOperateurs.pop();

			if(pileOperateurs.length !== 0 && estUneFonction(pileOperateurs.at(-1))) {
				pileSortie.push(pileOperateurs.pop());
			}
			break;

		case PLUS_ID:
		case MOINS_ID:
		case MULT_ID:
		case DIV_ID:
		case PUISSANCE_ID:
		case PLUS_UNAIRE_ID:
		case MOINS_UNAIRE_ID:
			while(pileOperateurs.length !== 0 && estUnOperateur(pileOperateurs.at(-1)) &&
				((Priorites[token] < Priorites[pileOperateurs.at(-1)] ||
				(Priorites[token] === Priorites[pileOperateurs.at(-1)] && Associativites[token] === GAUCHE)))) {
				pileSortie.push(pileOperateurs.pop());
			}

			pileOperateurs.push(token);
			break;

		default:
			if(token < NOMBRE_ID) {
				return(false);
			}

			pileSortie.push(token);
			break;
		}
	}

	while(pileOperateurs.length !== 0) {
		pileSortie.push(pileOperateurs.pop());
	}

	return(true);
}

// Indique si une parenthèse correspond à une fonction simple comme sin(3+x(exp(x)+2)) mais pas comme sin(3+x) + exp(x+2)
function parentheseFonctionSeule(expr)
{
	var compteParOuvrante = 0,compteParFermante = 0;
	var dernierIndexParOuvrante = 0,premierIndexParFermante = -1;

	for(var i=0;i < expr.length;i++) {
		if(expr.at(i) === "(" || expr.at(i) === "[") {
			compteParOuvrante++;
			dernierIndexParOuvrante = i;
		}

		if(expr.at(i) === ")" || expr.at(i) === "]") {
			compteParFermante++;

			if(premierIndexParFermante == -1)
				premierIndexParFermante = i;
		}
	}

	// On teste pour sin(3+x(exp(x)+2)) mais pas pour sin(3+x) + exp(x+2)
	if((compteParOuvrante !== 0) && (compteParOuvrante === compteParFermante) && (dernierIndexParOuvrante < premierIndexParFermante))
		return(true);

	return(false);
}

// Indique si une expression est un nombre seul, par exemple 5.425
function estUnNombre(expr)
{
	// On s'appuie sur une expression régulière
	var re = new RegExp("^(\\d+(?:\\.\\d+)?(?:E-?\\d+)?)");
	var match = expr.match(re);

	if(match && match[0].length !== 0)
		return(true); // on a bien un nombre

	return(false);
}

// Indique si une expression est un élément seul comme x ou 5.25
function estUnElementSeul(expr)
{
	// On a recours à deux expressions régulières
	let listeExpRegElemSeuls = ["^(x)$","^(\\d+(?:\\.\\d+)?(?:E-?\\d+)?)$"];
  
	for(var i=0;i < listeExpRegElemSeuls.length;i++) {
		var re = new RegExp(listeExpRegElemSeuls.at(i));
		var match = expr.match(re);
    
		if(match && match[0].length !== 0)
			return(true); // we have a single element
	}

	return(false);
}

// Indique si une expression est un élément seul (comme x) ou une fonction (par exemple sin(25+x)) ou n'a pas de signe plus ou moins en dehors des parenthèses
function estUnElementSeulOuUneFonction(expr)
{
	// On commence par tester si c'est un élément seul
	if(estUnElementSeul(expr)) {
		return(true); // oui
	}

	// Après cela, on regarde s'il s'agit d'une fonction avec des parenthèses
	let listExpRegFoncion = ["^(sin)","^(exp)"];
  
	for(var i=0;i < listExpRegFoncion.length;i++) {
		var re = new RegExp(listExpRegFoncion.at(i));
		var match = expr.match(re);
    
		if(match && match[0].length !== 0) {
			// On a trouvé une fonction : il faut vérifier s'il y a un simple couple de parenthèses
			if(parentheseFonctionSeule(expr))
				return(true);
  
			break; // on arrête la boucle
		}
	}
  
	// Notre dernière chance est de vérifier s'il n'y a pas de signe plus ou moins en dehors des parenthèses
	var compteurPar = 0;

	for(var i=0;i < expr.length;i++) {
		var car = expr.at(i);

		if(car === listeChaineToken.at(PAR_OUVRANTE_ID))
			compteurPar++;

		if(car === listeChaineToken.at(PAR_FERMANTE_ID))
			compteurPar--;

		if((car === listeChaineToken.at(PLUS_ID) || car === listeChaineToken.at(MOINS_ID)) && compteurPar == 0)
			return(false);
	}  
  
	return(true);
}

// Génère l'expresssion au format MathML en se basant sur la pile de sortie de l'algorithme de la gare de triage
function generationMathML()
{
	var op1,op2,op3,op4;
	var pileMathML = []; // pour le stockage des expressions MathML
	var pileExpr = []; // pile pour l'historique de travail
  
	// Si la pile de sortie est vide, une erreur s'est produite
	if(pileSortie.length === 0)
		return("");

	// On boucle tant qu'il y a des tokens dans la pile
	while(pileSortie.length !== 0) {
		var token = pileSortie.shift(); // on parcourt la pile depuis le bas
    
		switch(token) {
			case X_ID: // token x
				pileMathML.push("<mi>" + listeChaineToken.at(token) + "</mi>");
				pileExpr.push(listeChaineToken.at(token));
				break;

			case SIN_ID: // token sin
				if(pileMathML.length < 1) { // il faut un opérande
					return("");
				}

				op1 = pileMathML.pop();
				pileMathML.push("<mrow><mi>" + listeChaineToken.at(token) + "</mi><mo>(</mo>" + op1 + "<mo>)</mo></mrow>");
				
				op3 = pileExpr.pop();
				pileExpr.push(listeChaineToken.at(token) + "(" + op3 + ")");
				break;
		
			case EXP_ID: // token exponentielle
				if(pileMathML.length < 1) { // il faut un opérande
					return("");
				}

				op1 = pileMathML.pop();
				pileMathML.push("<msup><mrow>" + listeChaineToken.at(token) + "</mrow><mrow>" + op1 + "</mrow></msup>");
				
				op3 = pileExpr.pop();
				pileExpr.push(listeChaineToken.at(token) + "(" + op3 + ")");
				break;

			case PLUS_UNAIRE_ID: // token plus unaire				
				if(pileMathML.length < 1) { // il faut un opérande
					return("");
				}
				
				op1 = pileMathML.pop();

				// On vérifie que le premier caractère de l'opérande n'est pas un signe (deux opérateurs ne peuvent pas se suivre)
				op3 = pileExpr.pop();

				if(op3.at(0) === listeChaineToken.at(PLUS_ID) || op3.at(0) === listeChaineToken.at(MOINS_ID) || op3.at(0) === listeChaineToken.at(MULT_ID)) {
					// Des parenthèses sont requises autour de op1
					pileMathML.push("<mrow><mo>" + listeChaineToken.at(token) + "</mo><mo>(</mo>" + op1	+ "<mo>)</mo></mrow>");
					// Des parenthèses sont requises autour de op3
					pileExpr.push(listeChaineToken.at(token) + "(" + op3 + ")");
				} else {
					// Sans parenthèses
					pileMathML.push("<mrow><mo>" + listeChaineToken.at(token) + "</mo>" + op1 + "</mrow>");
					pileExpr.push(listeChaineToken.at(token) + op3);
				}
				break;
				
			case MOINS_UNAIRE_ID: // token moins unaire
				if(pileMathML.length < 1) { // il faut un opérande
					return("");
				}

				op1 = pileMathML.pop();

				// On regarde si l'opérande est un élément seul ou une fonction seule
				op3 = pileExpr.pop();

				if(estUnElementSeulOuUneFonction(op3)) {
					// Pas de parenthèses requises autour de op1
					pileMathML.push("<mrow><mo>" + listeChaineToken.at(token) + "</mo>" + op1 + "</mrow>");
					pileExpr.push(listeChaineToken.at(token) + op3);
				} else {
					// Des parenthèses sont requises autour de op1
					pileMathML.push("<mrow><mo>" + listeChaineToken.at(token) + "</mo><mo>(</mo>" + op1	+ "<mo>)</mo></mrow>");
					// Des parenthèses sont requises autour de op3
					pileExpr.push(listeChaineToken.at(token) + "(" + op3 + ")");
				}
				break;

			case PLUS_ID: // token plus binaire
				if(pileMathML.length < 2) { // il faut deux opérandes
					return("");
				}

				op1 = pileMathML.pop();
				op2 = pileMathML.pop();

				// On vérifie que le premier caractère du second opérande n'est pas un signe (deux opérateurs ne peuvent pas se suivre)
				op3 = pileExpr.pop();
				op4 = pileExpr.pop();

				if(op3.at(0) === listeChaineToken.at(PLUS_ID) || op3.at(0) === listeChaineToken.at(MOINS_ID) || op3.at(0) === listeChaineToken.at(MULT_ID)) {
					// Des parenthèses sont requises autour de op1
					pileMathML.push("<mrow>" + op2 + "<mo>" + listeChaineToken.at(token) + "</mo><mo>(</mo>" + op1 + "<mo>)</mo></mrow>");
					// Des parenthèses sont requises autour de op3
					pileExpr.push(op4 + listeChaineToken.at(token) + "(" + op3 + ")");
				} else {
					// Sans parenthèses
					pileMathML.push("<mrow>" + op2 + "<mo>" + listeChaineToken.at(token) + "</mo>" + op1 + "</mrow>");
					pileExpr.push(op4 + listeChaineToken.at(token) + op3);
				}
				break;

			case MOINS_ID: // token moins binaire
				if(pileMathML.length < 2) { // il faut deux opérandes
					return("");
				}

				op1 = pileMathML.pop();
				op2 = pileMathML.pop();

				// On regarde si le second opérande est un élément seul ou une fonction seule
				op3 = pileExpr.pop();
				op4 = pileExpr.pop();

				if(estUnElementSeulOuUneFonction(op3)) {
					// Pas de parenthèses requises autour de op1
					pileMathML.push("<mrow>" + op2 + "<mo>" + listeChaineToken.at(token) + "</mo>" + op1 + "</mrow>");
					pileExpr.push(op4 + listeChaineToken.at(token) + op3);
				} else {
					// Des parenthèses sont requises autour de op1
					pileMathML.push("<mrow>" + op2 + "<mo>" + listeChaineToken.at(token) + "</mo><mo>(</mo>" + op1 + "<mo>)</mo></mrow>");
					// Des parenthèses sont requises autour de op3
					pileExpr.push(op4 + listeChaineToken.at(token) + "(" + op3 + ")");
				}
				break;

			case MULT_ID: // token multiplication
				if(pileMathML.length < 2) { // il faut deux opérandes
					return("");
				}

				op1 = pileMathML.pop();
				op2 = pileMathML.pop();

				// On regarde si le second opérande est un élément seul ou une fonction seule
				op3 = pileExpr.pop();
				op4 = pileExpr.pop();

				if(estUnElementSeulOuUneFonction(op3) && estUnElementSeulOuUneFonction(op4)) {
					// Pas de parenthèses requises autour de op1
					// On regarde si on a un nombre, car dans ce cas, un point de multiplication doit être visible
					if(estUnNombre(op3) || estUnNombre(op4)) {
						pileMathML.push("<mrow>" + op2 + "<mo>&sdot;</mo>" + op1 + "</mrow>");
					} else {
						pileMathML.push("<mrow>" + op2 + "<mo>&InvisibleTimes;</mo>" + op1 + "</mrow>");
					}

					pileExpr.push(op4 + listeChaineToken.at(token) + op3);
				} else {
					if(estUnElementSeulOuUneFonction(op4)) {
						if(estUnNombre(op3) || estUnNombre(op4)) {
							// Des parenthèses sont requises autour de op1, avec un point de multiplication
							pileMathML.push("<mrow>" + op2 + "<mo>&sdot;</mo><mo>(</mo>" + op1 + "<mo>)</mo></mrow>");
						} else {
							// Des parenthèses sont requises autour de op1, sans point de multiplication
							pileMathML.push("<mrow>" + op2 + "<mo>&InvisibleTimes;</mo><mo>(</mo>" + op1 + "<mo>)</mo></mrow>");
						}
						
						pileExpr.push(op4 + listeChaineToken.at(token) + "(" + op3 + ")");
					} else {
						if(estUnElementSeulOuUneFonction(op3)) {
							if(estUnNombre(op3) || estUnNombre(op4)) {
								// Des parenthèses sont requises autour de op2
								pileMathML.push("<mrow><mo>(</mo>" + op2 + "<mo>)</mo><mo>&sdot;</mo>" + op1 + "</mrow>");
							} else {
								// Des parenthèses sont requises autour de op2
								pileMathML.push("<mrow><mo>(</mo>" + op2 + "<mo>)</mo><mo>&InvisibleTimes;</mo>" + op1 + "</mrow>");
							}

							pileExpr.push("(" + op4 + ")" + listeChaineToken.at(token) + op3);
						} else {
							if(estUnNombre(op3) || estUnNombre(op4)) {
								// Des parenthèses sont requises autour de op1 et op2
								pileMathML.push("<mrow><mo>(</mo>" + op2 + "<mo>)</mo><mo>&sdot;</mo><mo>(</mo>" + op1 + "<mo>)</mo></mrow>");
							} else {
								// Des parenthèses sont requises autour de op1 et op2
								pileMathML.push("<mrow><mo>(</mo>" + op2 + "<mo>)</mo><mo>&InvisibleTimes;</mo><mo>(</mo>" + op1 + "<mo>)</mo></mrow>");
							}

							pileExpr.push("(" + op4 + ")" + listeChaineToken.at(token) + "(" + op3 + ")");
						}
					}
				}
				break;

			case DIV_ID: // token division
				if(pileMathML.length < 2) { // il faut deux opérandes
					return("");
				}

				op1 = pileMathML.pop();
				op2 = pileMathML.pop();
				pileMathML.push("<mfrac><mrow>" + op2 + "</mrow><mrow>" + op1 + "</mrow></mfrac>");

				op3 = pileExpr.pop();
				op4 = pileExpr.pop();
				pileExpr.push("(" + op4 + "/" + op3 + ")");
				break;

			case PUISSANCE_ID: // token puissance
				if(pileMathML.length < 2) { // il faut deux opérandes
					return("");
				}

				op1 = pileMathML.pop();
				op2 = pileMathML.pop();

				// On regarde si le premier opérande est un élement seul (pour lequel aucune parenthèse n'est requise)
				op3 = pileExpr.pop();
				op4 = pileExpr.pop();

				if(estUnElementSeul(op4)) {
					// Aucune parenthèse requise autour de op2
					pileMathML.push("<msup><mrow>" + op2 + "</mrow><mrow>" + op1 + "</mrow></msup>");
				} else {
					// Parenthèses requises autour de op2
					pileMathML.push("<msup><mrow><mo>(</mo>" + op2 + "<mo>)</mo></mrow><mrow>" + op1 + "</mrow></msup>");
				}

				pileExpr.push("(" + op4 + ")^(" + op3 + ")");
				break;

			default: // nombre
				// Si la valeur de token est inférieure à NOMBRE_ID, il y a erreur
				if(token < NOMBRE_ID) {
					return("");
				}

				// Et si la valeur est trop grande, il y a également erreur
				if(token >= NOMBRE_ID + listeNombres.length) {
					return("");
				}

				// On prend le nombre dans la liste des nombres
				pileMathML.push("<mn>" +  listeNombres.at(token - NOMBRE_ID) + "</mn>");
				pileExpr.push(listeNombres.at(token - NOMBRE_ID));
				break;
		}
	}

	// S'il ne reste pas exactement un élément dans la pile, il y a une erreur
	if(pileMathML.length != 1) {
		return("");
	}

	// On retourne le résultat
	return(pileMathML.pop());
}

// Point d'entrée du script JavaScript
// En entrée, expr contient l'expression à analyser par exemple sin(3*x/2)/x
// En sortie, on renvoie l'expression au format MathML, prête à être affichée dans le navigateur
function obtientMathML(expr)
{
  obtientListeTokens(expr);

  if(listeTokens.length === 0) {
    return("");
  }
 
  gareDeTriage();

  if(pileSortie.length === 0) {
    return("");
  }

  return(generationMathML());
}
