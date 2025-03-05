# Réalise un OU exclusif entre deux chaines binaires, par exemple 110101 et 101
def ouExclusif(s1,s2)
	out = ""

	for i in 0..s2.length - 1
		# On utilise la définition du OU exclusif
		if((s1[i] == "0" and s2[i] == "0") or (s1[i] == "1" and s2[i] == "1")) then
			out += "0"
		else
			out += "1"
		end
	end

	# On recopie les caractères restants de s1, pour lesquels on ne fait pas de OU exclusif
	for i in s2.length..s1.length - 1
		out += s1[i]
	end
	
	out
end

# Réalise la division binaire basée sur les OU exclusifs
def division(s1,s2)
	while(s1.length >= s2.length) # on parcourt tous les caractères
		while(s1.length >= s2.length and s1.length > 0 and s1[0] == "0")
			s1 = s1[1..-1] # on enlève le premier caractère qui est un 0
		end
		
		if(s1.length >= s2.length)
			s1 = ouExclusif(s1,s2) # on réalise le OU exclusif
		end
	end

	s1
end

# Transforme une chaine de caractères ASCII en chaine binaire
def messageVersBinaire(s)
	out = ""

	# On parcourt tous les caractères en commençant par le dernier
	for i in (s.length() - 1).downto(0) 
		binStr = s[i].ord.to_s(2) # conversion du caractère en chaine binaire
		
		# On complète par des 0 si nécessaire pour atteindre 8 bits
		binStrLen = binStr.length

		for j in 0..8 - binStrLen - 1
			binStr.prepend("0")
		end

		out += binStr
	end

	out
end

# Inverse "nombre" bits d'une chaine
def inversionBits(s,nombre)
	out = ""

	for i in 0..nombre-1
		if s[i] == "0"
			out += "1"
		else
			out += "0"
		end
	end

	# On rajoute les éventuels bits non inversés
	for i in nombre..s.length() - 1
		out += s[i]
	end

	out
end

# Rajoute "nombre" bits à une chaine binaire
def ajoutBits(s,bit,nombre)
	for i in 0..nombre-1
		s += bit;
	end

	s
end

# Réalise une symétrie de la chaine binaire
def reflexionBits(s)
	s.reverse
end

message = "A" # le message dont il faut calculer le FCS
s1 = messageVersBinaire(message) # on transforme le message en binaire
s2 = reflexionBits(s1) # on fait une symétrie de tous les bits
s3 = ajoutBits(s2,"0",32) # on rajoute 32 bits valant 0
s4 = inversionBits(s3,32) # on inverse les 32 premiers bits
s5 = division(s4,"100000100110000010001110110110111") # on effectue la division polynomiale
s6 = reflexionBits(s5) # on fait une symétrie de tous les bits du reste
s7 = inversionBits(s6,s6.length()) # on inverse tous les bits
puts s7 # on affiche le FCS
