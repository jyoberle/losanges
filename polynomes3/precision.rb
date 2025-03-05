# Donne la meilleure partie décimale approchée d'un nombre exprimé en binaire
PREC = 6 # nombre de bits alloués à la partie décimale

# Point d'entrée de notre programme
if ARGV.length != 1
	puts "Veuillez indiquer un nombre"
	exit
end

nombre = ARGV[0].to_f
cible = nombre - nombre.floor # pour ne garder que la partie décimale
diff = 10000 # servira à calculer la différence entre le nombre et sa valeur approchée
appro = 0 # valeur approchée

# On parcourt toutes les combinaisons binaires possibles 
# pour générer toutes les parties décimales possibles
for i in 0..2**PREC - 1
	val = 0
	
	# Pour une partie décimale donnée, on calcule sa valeur en regardant les bits qui sont a 1
	for j in 1..PREC
		if i & 2**(j-1) != 0
			val = val + 2**(-j)
		end
	end
	
	# On compare la différence entre le nombre que l'on souhaite approcher
	# et la partie décimale courante
	# Si cette différence est la plus petite obtenue jusqu'à présent, on mémorise
	# cette partie décimale
	if (cible - val).abs < diff
		diff = (cible - val).abs #
		appro = val; # appro contiendra la valeur de la meilleure partie décimale approchée
	end
end

# On affiche la meilleure partie décimale approchée
puts("La meilleure valeur approchée de " + cible.to_s + " est " + appro.to_f.to_s)
