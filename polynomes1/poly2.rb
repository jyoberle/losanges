# Cette fonction calcule le FCS d'une chaine exprimée en hexadécimal
# par exemple FD895669711D
def FCS(s) # s est une chaine de caractères correspondant à des nombres hexadécimaux
	# Mettre la variable crc à 0xFFFFFFFF reviendra à inverser les 32 premiers bits du dividende
	crc = 0xFFFFFFFF
	
	# On parcourt la chaine en examinant à chaque fois deux chiffres hexadécimaux
	for i in (0..s.length - 1).step(2)
		# On convertit les deux chiffres hexadécimaux en une valeur (de 0 à 255)
		val = s[i..i + 1].hex
		crc = crc ^ val # OU exclusif entre la valeur précédente et la variable crc
		for j in 0..7
			if crc & 1 == 0 # on teste si le bit le plus à droite est un 1
				crc = (crc >> 1) # non, c'est un 0 : on fait un décalage de 1 bit vers la droite
			else
				# Oui, c'est un 1 : on fait le décalage suivi d'un OU exclusif 
				# avec le polynome de référence réfléchi (0xEDB88320)
				crc = (crc >> 1) ^ 0xEDB88320
			end
		end
	end
	
	crc = crc ^ 0xFFFFFFFF # OU exclusif final
end

# Message dont il faut calculer le FCS
message = "F4CAE55779DA7CD30A8232AC0800450000287D8D400080060000\
C0A80109D5BA210437EB01BB908FE921357A5BD05010FAF0B88A0000"
puts FCS(message).to_s(16) # on affiche le FCS
