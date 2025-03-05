# Simule un LFSR

# Polynome caractéristique T(x) = 1 + x^11 + x^13 + x^14 + x^16
$poly = [0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1]
# Registre du LFSR
$registre = Array.new($poly.length,0)

# Effectue un décalage du LFSR à partir de son polynome caractéristique poly
# Pour le résultat du OU exclusif, on se base sur le calcul du nombre de 1
def decalage()
	cnt = 0

	for i in 0..$poly.length - 1
		if $poly[i] == 1 and $registre[i] == 1
			cnt += 1 # on compte le nombre de 1
		end
	end	

	$registre.pop(1) # on retire le dernier élément
	$registre.unshift(cnt % 2 == 0 ? 0 : 1) # on décale d'un rang vers la droite
end

# On génère au hasard une première valeur du registre
srand()

for i in 0..$registre.length - 1
	$registre[i] = rand(2)
end

# On conserve une copie du contenu du registre initial
registre_depart = $registre.clone

# On affiche le contenu initial
puts $registre.join(' ')

for i in 1..2*65535
	decalage()
	
	if(registre_depart == $registre)
		# On signale qu'on est retombé sur la valeur initiale
		puts "Rebouclage au rang #{i.to_i}"
	end
end

# On affiche le contenu final
puts $registre.join(' ')
