# À l'instar d'une calculatrice, ce programme permet la saisie et le calcul approché
# de fonctions usuelles
# On attend indéfiniment des entrées de l'utilisateur : il faudra faire un Ctrl-C pour sortir
while true
	print "> " # on affiche l'invite pour l'utilisateur
	# Dans la ligne qui suit, on saisit l'entrée de l'utilisateur, on enlève le retour chariot
	# ainsi que tous les espaces, et on confronte le résultat à notre expression régulière
	entree = \
	gets.chomp.gsub(/[[:space:]]+/,"").match(/^(exp|sin)\((-?\d+(?:\.\d+)?(?:E-?\d+)?)\)$/)

	if(entree.nil?)
		puts "ERREUR" # l'utilisateur n'a pas fourni une entrée correcte
	else
		fonction,argument = entree.captures # on capture la fonction et son argument
		
		# Suivant la fonction, on effectue le calcul et on affiche le résultat
		case fonction
			when "exp"
				puts Math.exp(argument.to_f)
			when "sin"
				puts Math.sin(argument.to_f)
			# ici le else n'est pas nécessaire, car l'expression régulière nous garantit que
			# nous n'aurons à traiter que ces deux cas
		end
	end
		
end
		
