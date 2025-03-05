# À l'instar d'une calculatrice, ce programme permet les calculs avec les quatre opérations,
# la puissance et des fonctions usuelles

# Constantes
SIN_ID = 0
EXP_ID = 1
PAR_OUVRANTE_ID = 2
PAR_FERMANTE_ID = 3
PLUS_ID = 4
MOINS_ID = 5
MULT_ID = 6
DIV_ID = 7
PUISSANCE_ID = 8
PLUS_UNAIRE_ID = 9
MOINS_UNAIRE_ID = 10
NOMBRE_ID = 11
GAUCHE = 0
DROITE = 1
NA = 2

ListeExpregToken = ['^(sin)','^(exp)','^(\()','^(\))','^(\+)','^(-)','^(\*)','^(/)','^(\^)',
	'^(\+)','^(-)','^(\d+(?:\.\d+)?(?:E-?\d+)?)']
Priorites = {PLUS_ID  => 5, MOINS_ID => 5, MULT_ID => 10, DIV_ID => 10, PLUS_UNAIRE_ID => 15,
	MOINS_UNAIRE_ID => 15, PUISSANCE_ID => 20}
Associativites = { PLUS_ID  => GAUCHE, MOINS_ID => GAUCHE, MULT_ID => GAUCHE, DIV_ID => GAUCHE,
	PUISSANCE_ID => DROITE, PLUS_UNAIRE_ID => NA, MOINS_UNAIRE_ID => NA}

# Variables globales
$listeTokens = [] # liste où seront stockés les tokens de la chaine rentrée par l'utilisateur
$listeNombres = [] # liste où seront stockés les nombres de la chaine rentrée par l'utilisateur

# Définition de la classe Pile
class Pile
	def initialize()
		@pile = Array.new
	end

	def empiler(val) # permet d'empiler un élément
		@pile.push(val)
	end

	def depiler # permet de dépiler un élément
		return @pile.pop() # retourne nil si l'array est vide
	end
	
	def profondeur # donne le nombre d'éléments dans la pile
		return @pile.length()
	end
	
	def dernier # donne le dernier élément d'une pile sans le dépiler
		return(nil) if(@pile.length() == 0) # on retourne nil si la pile est vide		
		return @pile[-1]
	end
	
	def renverser # renverse le contenu de la pile
		@pile = @pile.reverse()
	end
	
	def vider # vide le contenu de la pile
		@pile.clear()
	end

	def afficher # affiche le contenu de la pile
		puts @pile
	end
end

# Création de la pile de sortie et de celle des opérateurs
$pileSortie = Pile.new
$pileOperateurs = Pile.new

# Extrait des tokens de la chaine rentrée par l'utilisateur
def obtientListeTokens(expr)
	index = 0
  
	$listeTokens = []
	$listeNombres = []
  
	expr = expr.chomp.gsub(/[[:space:]]+/,"")	# on enlève le retour chariot et tous les espaces
  
	while index != -1 and index < expr.length
		# On regarde s'il s'agit d'un signe plus
		if expr[index..].match(ListeExpregToken[PLUS_ID])
			# On regarde s'il est en position 0 ou s'il est précédé d'une parenthèse ouvrante
			if(index == 0 or expr[index - 1] == '(')
				$listeTokens.push(PLUS_UNAIRE_ID) # il s'agit d'un opérateur unaire
			else
				$listeTokens.push(PLUS_ID) # il s'agit d'un opérateur binaire
			end
		
			index = index + 1
			next # on a trouvé un token
		end
	
		# On regarde s'il s'agit d'un signe moins
		if expr[index..].match(ListeExpregToken[MOINS_ID])
			# On regarde s'il est en position 0 ou s'il est précédé d'une parenthèse ouvrante
			if(index == 0 or expr[index - 1] == '(')
				$listeTokens.push(MOINS_UNAIRE_ID) # il s'agit d'un opérateur unaire
			else
				$listeTokens.push(MOINS_ID) # il s'agit d'un opérateur binaire
			end
		
			index = index + 1
			next # on a trouvé un token
		end

		# On cherche un autre token qu'un signe plus ou moins
		tokenTrouve = false

		for i in 0..ListeExpregToken.length-1
			if match = expr[index..].match(ListeExpregToken[i])
				tokenTrouve = true
				index += match[1].length
		
				if i == NOMBRE_ID
					$listeTokens.push(i + $listeNombres.length)
					$listeNombres.push(match[1]) # les nombres sont stockés dans une liste séparée
				else
					$listeTokens.push(i)
				end
		
				break # on a trouvé un token
			end
		end

		if tokenTrouve == false
		# On n'a pas trouvé de token
			$listeTokens = []
			break
		end
	end
end

# Indique si un token est une fonction
def estUneFonction(token)
	case token
		when SIN_ID, EXP_ID
			return(true)
		else
			return(false)
	end
end

# Indique si un token est un opérateur
def estUnOperateur(token)
	case token
		when PLUS_ID, MOINS_ID, MULT_ID, DIV_ID, PUISSANCE_ID, PLUS_UNAIRE_ID, MOINS_UNAIRE_ID
			return(true)
		else
			return(false)
	end
end

# Applique l'algorithme de la gare de triage sur la liste de tokens
def gareDeTriage()
	for i in 0..$listeTokens.length-1
		token = $listeTokens[i]

		case token
			when SIN_ID, EXP_ID
				$pileOperateurs.empiler(token)

			when PAR_OUVRANTE_ID
				$pileOperateurs.empiler(PAR_OUVRANTE_ID)

			when PAR_FERMANTE_ID
				while $pileOperateurs.profondeur != 0 and $pileOperateurs.dernier != PAR_OUVRANTE_ID
				$pileSortie.empiler($pileOperateurs.depiler())
		end

		if $pileOperateurs.profondeur == 0
			return(false)
		end

		if $pileOperateurs.dernier != PAR_OUVRANTE_ID
			return(false)
		end

		$pileOperateurs.depiler()

		if $pileOperateurs.profondeur != 0 and estUneFonction($pileOperateurs.dernier)
			$pileSortie.empiler($pileOperateurs.depiler())
		end

		when PLUS_ID, MOINS_ID, MULT_ID, DIV_ID, PUISSANCE_ID, PLUS_UNAIRE_ID, MOINS_UNAIRE_ID
			while $pileOperateurs.profondeur != 0 and estUnOperateur($pileOperateurs.dernier) and
				((Priorites[token] < Priorites[$pileOperateurs.dernier] or
				(Priorites[token] == Priorites[$pileOperateurs.dernier] and 
				Associativites[token] == GAUCHE)))
				$pileSortie.empiler($pileOperateurs.depiler())
			end

			$pileOperateurs.empiler(token)

		else
			if token < NOMBRE_ID
				return(false)
			end

			$pileSortie.empiler(token)
		end
	end

	while $pileOperateurs.profondeur != 0
		$pileSortie.empiler($pileOperateurs.depiler())
	end

	return(true)
end

# On attend indéfiniment des entrées de l'utilisateur : il faudra faire un Ctrl-C pour sortir
while true
	print "> " # on affiche l'invite pour l'utilisateur
	entree = gets.chomp.gsub(/[[:space:]]+/,"")	# on enlève le retour chariot et tous les espaces
	next if(entree.length == 0) # s'il n'y a rien à traiter, on retourne au début de la boucle
	$pileSortie.vider() # c'est une nouvelle ligne : les deux piles sont vidées
	$pileOperateurs.vider()
	obtientListeTokens(entree) # on extrait la liste des tokens de l'entrée de l'utilisateur

	# Si la liste des tokens est vide c'est qu'il y a une erreur dans l'entrée
	if $listeTokens.length() == 0 then puts "ERREUR";next end

	# On applique l'algorithme de la gare de triage
	if gareDeTriage() == false then puts "ERREUR"; next end
	
	$pileSortie.renverser() # on renverse le contenu de la pile de sortie
	
	pile = Pile.new # pile pour le calcul de l'expression
	
	# On analyse le contenu de la pile de sortie et on remplit la pile de calcul
	while $pileSortie.profondeur > 0
		entree = $pileSortie.depiler
	
		case entree
			when PLUS_ID
				next if(pile.profondeur < 2) # s'il y a moins de deux opérandes, on ne fait rien
				arg1 = pile.depiler() # on dépile les deux opérandes
				arg2 = pile.depiler()
				resultat = arg2 + arg1 # addition
				pile.empiler(resultat) # le résultat de l'addition est mis sur le dessus de la pile
			when MOINS_ID
				next if(pile.profondeur < 2)
				arg1 = pile.depiler()
				arg2 = pile.depiler()
				resultat = arg2 - arg1 # soustraction : l'ordre des opérandes est important ici
				pile.empiler(resultat)
			when PLUS_UNAIRE_ID
				next if(pile.profondeur < 1)
				# L'opération consisterait ici à multiplier l'argument par 1, donc on ne fait rien
			when MOINS_UNAIRE_ID
				next if(pile.profondeur < 1)
				arg = pile.depiler()
				resultat = -arg
				pile.empiler(resultat)
			when MULT_ID
				next if(pile.profondeur < 2)
				arg1 = pile.depiler()
				arg2 = pile.depiler()
				resultat = arg2 * arg1 # multiplication
				pile.empiler(resultat)
			when DIV_ID
				next if(pile.profondeur < 2)
				arg1 = pile.depiler()
				arg2 = pile.depiler()
				resultat = arg2 / arg1 # division
				pile.empiler(resultat)
			when PUISSANCE_ID
				next if(pile.profondeur < 2)
				arg1 = pile.depiler()
				arg2 = pile.depiler()
				resultat = arg2**arg1 # puissance
				pile.empiler(resultat)				
			when SIN_ID
				next if(pile.profondeur < 1)
				arg = pile.depiler()
				resultat = Math.sin(arg) # sinus
				pile.empiler(resultat)
			when EXP_ID
				next if(pile.profondeur < 1)
				arg = pile.depiler()
				resultat = Math.exp(arg) # exponentielle
				pile.empiler(resultat)
			else
				# C'est ici nécessairement un nombre : on l'empile simplement en le convertissant en
				# sa valeur
				# Le test ici ne serait pas nécessaire si la syntaxe mathématique de l'expression de
				# l'utilisateur était vérifiée (voir l'article pour plus de détails)
				if (entree >= NOMBRE_ID) then pile.empiler($listeNombres[entree - NOMBRE_ID].to_f) else
					pile.empiler(0) end
			end
	end
	
	# On affiche le contenu de la pile si elle ne contient qu'un seul élément
	# Dans le cas contraire, l'expression de l'utilisateur n'était pas correcte
	if(pile.profondeur != 1) then puts "ERREUR" else puts pile.afficher	end
end

