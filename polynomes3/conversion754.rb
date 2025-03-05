# Convertit un nombre exprimé en décimal (sous forme de chaine de caractères)
# au format IEEE 754

# On utilise une table des puissances de 10 qui est précalculée dans la mémoire de l'ordinateur
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

	# On vérifie également que le nombre n'est pas trop grand ni trop petit
	if nombre.to_f.abs > PLUS_GRAND
		puts("ERREUR : le nombre est trop grand.")
		exit
	end

	if nombre.to_f.abs < PLUS_PETIT
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
				# On prend le premier chiffre de la partie décimale 
				# pour le transférer à la partie entière
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
	
	# On complémente avec d'éventuels 0 à gauche
	if exposantBin.length < 8
		complement = 8 - exposantBin.length
		exposantBin = "0"*complement + exposantBin
	end
	
	# On retourne le résultat
	return(signeBin + exposantBin + entierBin + decimalBin)
end

# Point d'entrée de notre programme
if ARGV.length != 1
	puts "Veuillez indiquer un nombre à convertir"
	exit
end

nombre = ARGV[0]
puts("Le nombre " + nombre + " converti au format IEEE 754 vaut " + conversion754(nombre))
