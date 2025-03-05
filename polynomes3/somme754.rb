# Additionne deux nombre au format IEEE 754

# Effectue un décalage de n à droite d'un nombre exprimé sous forme de chaine de caractères
def decalageDroite(nombre,n)
	return "0"*n + nombre
end

# Convertit un nombre binaire (sous forme de chaine de caractères) en décimal
def bindec(nombre)
	resultat = 0
	
	for i in 0..nombre.length - 1
		if nombre[i] == "1" 
			resultat = resultat + (1 << (nombre.length - i - 1))
		end
	end
	
	return resultat
end

# Convertit un nombre décimal en binaire (sous forme de chaine de caractères)
def decbin(nombre)
	nombreBin = ""
	
	loop do
		break if nombre == 0 

		if(nombre & 1 == 0) # On regarde le bit le plus à droite (bit de poids faible)
			nombreBin = "0" + nombreBin
		else
			nombreBin = "1" + nombreBin
		end
		
		nombre = nombre >> 1 # On décale d'un rang vers la droite
	end
	
	return(nombreBin)
end

# Additionne deux nombres binaires (sous forme de chaine de caractères)
def addition(nombre1,nombre2)
	resultat = ""

	# S'il le faut, on rajoute des zéros à droite du nombre le plus court
	# Il s'agit de zéros rajoutés par définition après la virgule, donc le nombre ne change pas
	if(nombre1.length < nombre2.length)
		delta = nombre2.length - nombre1.length
		nombre1 = nombre1 + "0"*delta
	else
		if(nombre1.length > nombre2.length)
			delta = nombre1.length - nombre2.length
			nombre2 = nombre2 + "0"*delta
		end
	end
		
	# A ce stade, les deux nombres ont la même longueur : on peut les additionner
	retenue = "0"
	
	for i in (nombre1.length).downto(0)
		if(nombre1[i] == "0" && nombre2[i] == "0")
			resultat = retenue + resultat
			retenue = "0" # la retenue éventuelle a été "consommée"
		end
		
		if(nombre1[i] == "1" && nombre2[i] == "1")
			resultat = retenue + resultat
			retenue = "1" # la retenue éventuelle a été "consommée" mais une nouvelle est générée
		end
		
		if((nombre1[i] == "0" && nombre2[i] == "1") || (nombre1[i] == "1" && nombre2[i] == "0"))
			if(retenue == "1")
				resultat = "0" + resultat
				retenue = "1" # la retenue a été "consommée" mais une nouvelle est générée
			else
				resultat = "1" + resultat
			end
		end
	end
	
	if(retenue == "1")
		resultat = retenue + resultat # il faut ajouter la dernière retenue
	end
	
	return retenue,resultat
end

# Aditionne deux nombres au format IEEE 754
def addition754(nombre1,nombre2)
	# On vérifie que les nombres ont le bon format à l'aide d'une expression régulière
	regex = %r{^[0-1]{32}$}
	
	if !regex.match(nombre1)
		puts("ERREUR : " + nombre1.to_s + " ne suit pas le bon format.");
		exit;
	end

	if !regex.match(nombre2)
		puts("ERREUR : " + nombre2.to_s + " ne suit pas le bon format.");
		exit;
	end
	
	# On vérifie également que les deux nombres sont de même signe
	if(nombre1[0] != nombre2[0])
		puts("ERREUR : les deux nombres ont des signes différents.");
		exit;	
	end
	
	# On traite le cas particulier des zéros
	if nombre1 == "1" + "0"*31  and nombre2 == "1" + "0"*31
		return("1" + "0"*31) # les deux sont des zéros négatifs
	end
		
	 if nombre1 == "0"*32  and nombre2 == "0"*32
		return("0"*32) # les deux sont des zéros positifs
	end
	
	if nombre1 == "0"*32 or nombre1 == "1" + "0"*31
		return(nombre2) # le premier nombre est un zéro
	end
	
	if nombre2 == "0"*32 or nombre2 == "1" + "0"*31
		return(nombre1) # le second nombre est un zéro
	end

	signe1 = nombre1[0]
	exposant1 = nombre1[1..8]
	# On ajoute le "1" implicite au début pour obtenir la mantisse
	mantisse1 = "1" + nombre1[9..31]
	signe2 = nombre2[0]
	exposant2 = nombre2[1..8]
	# On ajoute le "1" implicite au début pour obtenir la mantisse
	mantisse2 = "1" + nombre2[9..31]

	exposant1Valeur = bindec(exposant1)
	exposant2Valeur = bindec(exposant2)

	# On détermine l'exposant le plus petit pour savoir comment aligner les mantisses
	exposantValeur = exposant1Valeur

	if exposant1Valeur < exposant2Valeur
		# Ici l'exposant du premier nombre est le plus petit
		decalage = exposant2Valeur - exposant1Valeur
		mantisse1 = decalageDroite(mantisse1,decalage)
		exposantValeur = exposant2Valeur
	else
		if exposant1Valeur > exposant2Valeur
			# Ici l'exposant du second nombre est le plus petit
			decalage = exposant1Valeur - exposant2Valeur
			mantisse2 = decalageDroite(mantisse2,decalage)
			exposantValeur = exposant1Valeur
		end
	end

	retenue,mantisse = addition(mantisse1,mantisse2)

	if(retenue == "1")
		# Si la retenue finale vaut 1, c'est que le résultat possède un chiffre de plus
		# dans la partie entière
		# Il faut donc réaliser un décalage, c'est-à-dire incrémenter l'exposant
		exposantValeur = exposantValeur + 1
	end

	# On enlève le premier 1 de la mantisse car celui-ci est implicite
	mantisse = mantisse[1..-1]

	# Il faut encore arrondir car la mantisse est limitée à 23 bits
	# On suit alors la méthodologie suivante :
	# Si l'avant-dernier chiffre est un 0, alors le dernier devient un 0
	# Si l'avant-dernier chiffre est un 1 et qu'il y a au moins un autre 1,
	# alors le dernier chiffre devient un 1, sinon un 0
	mantisse = mantisse[0..22]

	if mantisse[21] == "0"
		mantisse[22] = "0"
	else
		# Y a-t-il un autre "1"
		autreUn = false
		
		for i in 0..20
			if mantisse[i] == "1"
				autreUn = true
				break
			end
		end
		
		if autreUn == true
			mantisse[22] = "1"
		else
			mantisse[22] = "0"
		end
	end

	# On transforme l'exposant en chaine binaire
	exposantBin = decbin(exposantValeur)

	# On retourne le résultat
	return(signe1 + exposantBin + mantisse + "\n")
end

# Point d'entrée de notre programme
if ARGV.length != 2
	puts "Veuillez indiquer deux nombres à sommer"
	exit
end

nombre1 = ARGV[0]
nombre2 = ARGV[1]
puts("La somme de " + nombre1 + " et " + nombre2 + " vaut "  + addition754(nombre1,nombre2))
