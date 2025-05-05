// formuleMathML contiendra l'expression convertie en MathML
var formuleMathML = "";

// Fonction appelée lors du clic sur le bouton Abracadabra !
function Clic() {
	// On récupère l'entrée de l'utilisateur
	var entree = document.getElementById("fonction").value.split(' ').join('');

	if(entree === "") {
		// L'utilisateur n'a rien rentré
		formuleMathML = "";
	} else {
		// On convertit au format MathML
		formuleMathML = obtientMathML(entree);
	}

	// On affiche la formule en MathML
	document.getElementById("gare").innerHTML = "<math>" + formuleMathML + "</math>";
}
