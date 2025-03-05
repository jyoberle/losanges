# Estime la qualité d'un générateur pseudo-aléatoire en exploitant le test des anniversaires
# Sont testés ici notre LFSR et le générateur de Ruby

# Polynome caractéristique T(x) = 1 + x^11 + x^13 + x^14 + x^16
$poly = [0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1]
# Registre du LFSR
$registre = Array.new($poly.length,0)
# Nombre de bits du LFSR à considérer
$bits = 14

# Remplit le LFSR avec une valeur initiale
# On a recours à la fonction dédiée de Ruby
def initialisation_lfsr()
	srand()
		
	for i in 0..$registre.length - 1
		$registre[i] = rand(2)
	end
end

# Initialisation du générateur de Ruby
def initialisation_ruby()
	srand()
end

# Effectue un décalage du registre à partir de son polynome caractéristique poly
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

# Obtient un jeu de valeurs du LFSR
# Ce jeu est retourné sous la forme d'un tableau
def valeurs_lfsr(n)
	valeurs = Array.new(n,0)

	for i in 0..n - 1
		decalage()
		valeur = 0
			
		for j in 0..$bits - 1
			valeurs[i] = valeurs[i] + $registre[j]*2**j
		end
	end

	return(valeurs)
end

# Obtient un jeu de valeurs de Ruby
# Ce jeu est retourné sous la forme d'un tableau
def valeurs_ruby(n)
	valeurs = Array.new(n,0)

	for i in 0..n - 1
		valeurs[i] = rand(2**$bits + 1)
	end

	return(valeurs)
end

# Compte le nombre de répétitions dans un jeu de valeurs
def comptage_repetitions(valeurs)
	valeurs.sort!
	
	prev = valeurs[0]
    repetitions = 0
	
	for i in 1..valeurs.size - 1
		curr = valeurs[i]
		
		if(prev == curr)
			repetitions = repetitions + 1
		end
		
		prev = curr
	end
	
    return(repetitions)
end

# Probabilité souhaitée
p = 0.99
# Nombre de "jours"
d = (2**$bits).to_f 
# Nombre de tirages
n = Math.sqrt(2*d*Math.log((1/(1-p)))).ceil
# Nombre de répétitions théorique
r = d - d*((d-1)/d)**n - n*((d-1)/d)**(n-1)
# Nombre d'essais
essais = 10
	
puts "Nombre de tirages : " + n.to_s
puts "Nombre de répétitions théorique : " + r.to_s

# On génère au hasard une première valeur du registre
initialisation_lfsr()

# Puis on génère 10 valeurs pour notre LFSR
moyenne_repetitions = 0.0

for i in 1..essais
	valeurs = valeurs_lfsr(n)
	repetitions = comptage_repetitions(valeurs)
	moyenne_repetitions = moyenne_repetitions + repetitions
end

puts "Moyenne des répétitions (LFSR) : " + (moyenne_repetitions/essais).to_s

# Puis on génère 10 valeurs pour Ruby
moyenne_repetitions = 0.0
initialisation_ruby()

for i in 1..essais
	valeurs = valeurs_ruby(n)
	repetitions = comptage_repetitions(valeurs)
	moyenne_repetitions = moyenne_repetitions + repetitions
end

puts "Moyenne des répétitions (Ruby) : " + (moyenne_repetitions/essais).to_s
