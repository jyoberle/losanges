# Convertit un nombre au format IEEE 754 (sous forme de chaine de caractères) en décimal

# Biais des exposants
BIAIS = 127

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
if ARGV.length != 1
	puts "Veuillez indiquer un nombre à convertir"
	exit
end

nombre = ARGV[0]
puts("Le nombre " + nombre + " converti au format décimal vaut " + conversionDecimal(nombre))
