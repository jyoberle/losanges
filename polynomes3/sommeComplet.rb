# Additionne deux nombre au format en ayant recours au format IEEE 754

#### conversion754.rb ####

# On utilise une table des puissances de 10 qui est precalculée dans la mémoire de l'ordinateur
PUISSANCES = [10**0,10**1,10**2,10**3,10**4,10**5,10**6,10**7,10**8,10**9,
				10**10,10**11,10**12,10**13,10**14,10**15,10**16,10**17,10**18,10**19,
				10**20,10**21,10**22,10**23,10**24,10**25,10**26,10**27,10**28,10**29,
				10**30,10**31,10**32,10**33,10**34,10**35,10**36,10**37,10**38,10**39,
				10**40,10**41,10**42,10**43,10**44,10**45,10**46,10**47,10**48,10**49
				]
# Biais des exposants
BIAIS = 127
# Plus petit nombre possible
PLUS_PETIT = 1.17549435*10**(-38)
# Plus grand nombre possible
PLUS_GRAND = 3.4022346*10**(38)
# Pour limiter les puissances de 10, on n'admet pas plus de 10 caractères
MAX_CARACTERES = 10

def conversion754(nombre)
	# On transforme une éventuelle virgule en point
	nombre = nombre.gsub(',','.')

	# On vérifie que le nombre a le bon format à l'aide d'une expression régulière
	regex = %r{^[\+|-]?\d+(?:\.\d+)?(?:[e|E][\+|-]?\d+)?$}
	if !regex.match(nombre)
		puts("ERREUR : " + nombre.to_s + " ne suit pas le bon format.")
		exit
	end
	
	# Pour limiter les puissances de 10, on n'admet pas plus de 10 caractères
	if nombre.length > MAX_CARACTERES
		puts("ERREUR : plus de " + MAX_CARACTERES.to_s + " caractères.")
		exit
	end
	
	# On traite les cas particuliers 0 et -0
	if nombre.to_f == 0.0
		if nombre[0] == "-"
			return "1" + "0"*31 # c'est un zéro négatif
		end
		
		return "0"*32
	end

	# On vérifie également que le nombre n'est pas plus grand que 1E38 ni plus petit que 1E-38
	if nombre.to_f.abs > PLUS_GRAND
		puts("ERREUR : le nombre est trop grand.")
		exit
	end

	if nombre.gsub(',','.').to_f.abs < PLUS_PETIT
		puts("ERREUR : le nombre est trop petit.")
		exit
	end
		
	# On détermine le signe du nombre 
	signeBin = "0" # contiendra le signe du nombre : "0" pour positif, "1" pour négatif
	i = 0 # i va nous permettre de parcourir la chaine décrivant le nombre

	if nombre[i] == "-"
		signeBin = "1"
		i = i + 1
	end

	if nombre[i] == "+" 
		i = i + 1
	end
	
	# On extrait la partie entière
	entier = ""

	loop do
		break if i == nombre.length or nombre[i] == "." or nombre[i] == "E" or nombre[i] == "e"
		entier = entier + nombre[i]
		i = i + 1
	end
	
	# On extrait une éventuelle partie décimale
	decimal = ""

	if nombre[i] == "."
		# Il y a une partie décimale
		i = i + 1
		
		# On détermine la longueur de cette partie décimale
		loop do
			break if i == nombre.length or nombre[i] == "E" or nombre[i] == "e"
			decimal = decimal + nombre[i]
			i = i + 1
		end
	end

	# On recherche un éventuel exposant (de puissance de 10)
	exposantValeur = 0
	exposantSigne = 1 # contiendra le signe de l'exposant : 1 pour positif, -1 pour négatif
	
	if nombre[i] == "E" or nombre[i] == "e"
		# Il y a un exposant
		i = i + 1
		
		# On détermine le signe de cet exposant
		if nombre[i] == "-"
			exposantSigne = -1
			i = i + 1
		end
			
		if nombre[i] == "+"
			i = i + 1
		end
		
		# On calcule la valeur de cet exposant (il termine le nombre)
		for j in i..nombre.length - 1
			exposantValeur = exposantValeur + nombre[j].to_i * PUISSANCES[nombre.length - j - 1]
		end
	end
	
	# On fixe le signe de l'exposant
	exposantValeur = exposantSigne * exposantValeur
		
	# On ajuste les valeurs des parties entières et décimales pour tenir compte de l'exposant
	if exposantValeur > 0
		for i in 0..exposantValeur - 1
			if(decimal.length > 0)
				# On prend le premier de la partie décimale pour le transférer à la partie entière
				entier = entier + decimal[0]
				decimal = decimal[1..-1]
			else
				# Il n'y a pas (plus) de partie décimale :
				# on rajoute un 0 à la fin de la partie entière
				entier = entier + "0"
			end
		end
	else
		if exposantValeur < 0
			for i in 0..exposantValeur.abs - 1
				if entier.length > 0
					# On prend le dernier chiffre de la partie entière pour le transférer
					# à la partie décimale
					decimal = entier[-1] + decimal
					entier = entier[0..-2]
				else
					# Il n'y a pas (plus) de partie entière : on rajoute un 0
					# au début de la partie entière
					decimal = "0" + decimal
				end
			end
		end
	end
		
	# On calcule la valeur de la partie entière
	entierValeur = 0
	
	for i in 0..entier.length - 1
		entierValeur = entierValeur+(entier[i].ord-"0".ord)*PUISSANCES[entier.length-i-1]
	end

	# On calcule la valeur de la partie décimale
	decimalValeur = 0
	
	for i in 0..decimal.length - 1
		decimalValeur = decimalValeur+(decimal[i].ord-"0".ord)*PUISSANCES[decimal.length-i-1]
	end
			
	entierBin = ""

	loop do
		break if entierValeur == 0 

		if(entierValeur & 1 == 0)
			entierBin = "0" + entierBin
		else
			entierBin = "1" + entierBin
		end
		
		entierValeur = entierValeur >> 1
	end
			
	# On calcule la valeur de l'exposant et on détermine en même temps
	# la partie décimale en binaire
	exposantValeurBin = 0
	decimalBin = ""
	
	# Le premier 1 étant implicite, il nous faut éventuellement effectuer un décalage
	# L'exposant binaire sera ajusté pour tenir compte de ce décalage
	if(entierBin.length > 0)
		# Si la chaine de l'entier n'est pas vide,
		# alors par construction son premier chiffre est un 1
		# On retire ce premier 1 (implicite) et on ajuste l'exposant en conséquence
		entierBin = entierBin[1..-1]
		exposantValeurBin = entierBin.length

		# Puis on détermine les chiffres (binaires) de la partie décimale
		for i in 1..23 - entierBin.length
			decimalValeur = decimalValeur << 1
					
			if(decimalValeur < 10**(decimal.length))
				decimalBin = decimalBin + "0"
			else
				decimalBin = decimalBin + "1"
				decimalValeur = decimalValeur - 10**(decimal.length)
			end
		end
	else
		# Ici, la chaine de l'entier est vide : on fait les calculs jusqu'à trouver
		# un premier 1 dans la partie décimale binaire
		loop do
			break if decimalValeur >= 10**(decimal.length)
			decimalValeur = decimalValeur << 1
			exposantValeurBin = exposantValeurBin - 1
		end
		
		decimalValeur = decimalValeur - 10**(decimal.length)
		
		# Il nous reste à calculer la partie décimale après ce premier 1
		for i in 1..23
			decimalValeur = decimalValeur << 1
					
			if(decimalValeur < 10**(decimal.length))
				decimalBin = decimalBin + "0"
			else
				decimalBin = decimalBin + "1"
				decimalValeur = decimalValeur - 10**(decimal.length)
			end
		end
	end

	# On biaise l'exposant
	exposantValeurBin = exposantValeurBin + BIAIS

	# On transforme cette valeur de l'exposant en binaire
	exposantBin = ""

	loop do
		break if exposantValeurBin == 0 

		if(exposantValeurBin & 1 == 0)
			exposantBin = "0" + exposantBin
		else
			exposantBin = "1" + exposantBin
		end
		
		exposantValeurBin = exposantValeurBin >> 1
	end
	
	# On complémente avec d'éventuels 0 à droite
	if exposantBin.length < 8
		complement = 8 - exposantBin.length
		exposantBin = "0"*complement + exposantBin
	end
	
	# On retourne le résultat
	return(signeBin + exposantBin + entierBin + decimalBin)
end

#### somme754.rb ####

# Effectue un decalage de n à droite d'un nombre exprimé sous forme de chaine de caractères
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

# Convertit un nombre decimal en binaire (sous forme de chaine de caractères)
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

	# S'il le faut, on rajoute des zéros à gauche du nombre le plus court
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
	# On verifie que les nombres ont le bon format à l'aide d'une expression régulière
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
		# Il faut donc réalise un décalage, c'est-à-dire incrémenter l'exposant
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

#### conversionDecima.rb ####

def conversionDecimal(nombre)
	# On vérifie que les nombres ont le bon format à l'aide d'une expression régulière
	regex = %r{^[0-1]{32}$}
	
	if !regex.match(nombre)
		puts("ERREUR : " + nombre.to_s + " ne suit pas le bon format.");
		exit;
	end
	
	# On traite le cas particulier des zéros
	if nombre == "0"*32
		return("0") # c'est un zéro positif
	end 

	if nombre == "1" + "0"*31
		return("-0") # c'est un zéro négatif
	end 
	
	signeValeur = nombre[0] == "1" ? -1 : 1
	exposantValeur = bindec(nombre[1..8]) - BIAIS
	mantisse = "1" + nombre[9..31] # on rajoute le 1 implicite à la mantisse
	mantisseValeur = 0
	
	for i in 0..mantisse.length - 1
		if mantisse[i] == "1"
			mantisseValeur += 2**(-i)
		end
	end
	
	return((signeValeur * mantisseValeur * 2**exposantValeur).to_f.to_s)
end

# Point d'entrée de notre programme
if ARGV.length != 2
	puts "Veuillez indiquer deux nombres à sommer"
	exit
end

nombre1 = ARGV[0]
nombre2 = ARGV[1]
nombre1_754 = conversion754(ARGV[0])
nombre2_754 = conversion754(ARGV[1])
resultat754 = addition754(nombre1_754,nombre2_754)
resultat = conversionDecimal(resultat754)
puts("La somme de " + nombre1 + " et " + nombre2 + " vaut "  + resultat)
