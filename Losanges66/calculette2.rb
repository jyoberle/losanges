# À l'instar d'une calculatrice, ce programme permet les calculs avec les quatre opérations
# et des fonctions usuelles
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
end

pile = Pile.new # création d'une pile

# On attend indéfiniment des entrées de l'utilisateur : il faudra faire un Ctrl-C pour sortir
while true
	print "> " # on affiche l'invite pour l'utilisateur
	entree = gets.chomp.gsub(/[[:space:]]+/,"")	# on enlève le retour chariot et tous les espaces
	next if(entree.length == 0) # s'il n'y a rien à traiter, on retourne au début de la boucle

	# On regarde si la saisie est un nombre grâce à notre expression régulière
	if(entree.match(/^-?\d+(\.\d+)?(E-?\d+)?$/))
		pile.empiler(entree.to_f) # il s'agit bien d'un nombre : on le place au sommet de la pile
		next # on repart au début de la boucle
	end
	
	# Puisque l'entrée de l'utilisateur n'est pas un nombre, c'est normalement une opération
	# ou une fonction
	case entree
		when("+")
			next if(pile.profondeur < 2) # s'il y a moins de deux opérandes, on ne fait rien
			arg1 = pile.depiler() # on dépile les deux opérandes
			arg2 = pile.depiler()
			resultat = arg2 + arg1 # addition
			pile.empiler(resultat) # le résultat de l'addition est mis sur le dessus de la pile
			puts resultat
		when("-")
			next if(pile.profondeur < 2)
			arg1 = pile.depiler()
			arg2 = pile.depiler()
			resultat = arg2 - arg1 # soustraction : l'ordre des opérandes est important ici
			pile.empiler(resultat)
			puts resultat
		when("*")
			next if(pile.profondeur < 2)
			arg1 = pile.depiler()
			arg2 = pile.depiler()
			resultat = arg2 * arg1 # multiplication
			pile.empiler(resultat)
			puts resultat
		when("/")
			next if(pile.profondeur < 2)
			arg1 = pile.depiler()
			arg2 = pile.depiler()
			resultat = arg2 / arg1 # division
			pile.empiler(resultat)
			puts resultat
		when("exp")
			next if(pile.profondeur < 1)
			arg = pile.depiler()
			resultat = Math.exp(arg) # exponentielle
			pile.empiler(resultat)
			puts resultat
		when("sin")
			next if(pile.profondeur < 1)
			arg = pile.depiler()
			resultat = Math.sin(arg) # sinus
			pile.empiler(resultat)
			puts resultat
		else
			puts "ERREUR" # l'opération ou la fonction sont inconnues
	end
end

		
