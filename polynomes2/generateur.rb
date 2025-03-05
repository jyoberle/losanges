# Teste toutes les valeurs de graine pour le générateur de Lehmer du ZX81

# Valeurs des paramètres
a = 75
c = 74
m = 65537

hash = {} # ce hachage sera rempli au fur et à mesure avec les éléments de la suite

for x0 in 0..m-1
	hash.clear() # on efface le hachage pour ce nouveau tour de boucle
	xn = x0 # valeur initiale
	for i in 1..m-1
		if(hash.has_key?(xn))
			puts "Répétition pour x0 = " + x0.to_s + " au rang i = " + i.to_s
			exit
		end
		
		hash[xn] = 1 # on mémorise ce terme de la suite dans la clé
		xn = (a * xn + c) % m # formule de Lehmer
	end
end
