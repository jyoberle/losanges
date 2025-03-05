MEM_SIZE = 256 # taille de la mémoire
BYTE_MAX = 256 # valeur maximale d'un octet + 1
ADDR_START_CODE = 128 # adresse de début du code à exécuter
s = "Fin inattendue du code à l'adresse" # chaine multiple

# input contient le nom du fichier mémoire, out le fichier mémoire qui sera écrit
def simulate(input,out)
	# On lit le contenu de la mémoire en convertissant les chaines en nombres
	mem = File.readlines(input).map(&:to_i) rescue abort("Impossible de lire " + input)
	# On vérifie la taille du fichier et que toutes ses valeurs soient comprises entre 0 et 255
	abort("Taille incorrecte de " + input) if(mem.length != MEM_SIZE)
	abort("Valeur erronée dans " + input) if(!mem.all? { |e| e >= 0 and  e < BYTE_MAX})
	acc = rand(0..255) # l'accumulateur est initialisé avec une valeur aléatoire
	r = rand(0..1) # le bit de retenue est initialisé avec une valeur aléatoire
	z = rand(0..1) # le bit de zéro est initialisé avec une valeur aléatoire
	i = ADDR_START_CODE # on exécute le code dans la mémoire, à partir de l'adresse 128
		
	while(i < MEM_SIZE)
		case mem[i]
			# On décode chaque code opération pour l'exécuter
			when 1 # Le contenu de l'accumulateur est écrit en mémoire à l'adresse indiquée
				abort(s+i.to_s) if(!mem[i+1]);mem[mem[i+1]] = acc;i += 2
			when 2 # L'accumulateur est chargé avec une valeur immédiate
				abort(s+i.to_s) if(!mem[i+1]);acc = mem[i+1];z = (acc == 0) ? 1:0;i += 2
			when 3 # L'accumulateur est chargé avec une valeur contenue en mémoire
				abort(s+i.to_s) if(!mem[i+1]);acc = mem[mem[i+1]];z = (acc == 0) ? 1:0;i += 2
			when 4 # On additionne une valeur immédiate à l'accumulateur
				abort(s+i.to_s) if(!mem[i+1]);r = (acc + mem[i+1] >= BYTE_MAX) ? 1:0
				acc = (acc + mem[i+1]) % BYTE_MAX;z = (acc == 0) ? 1:0;i += 2
			when 5 # On additionne une valeur contenue en mémoire à l'accumulateur
				abort(s+i.to_s) if(!mem[i+1]);r = (acc + mem[mem[i+1]] >= BYTE_MAX) ? 1:0
				acc = (acc + mem[mem[i+1]]) % BYTE_MAX;z = (acc == 0) ? 1:0;i += 2
			when 6 # on arrête l'exécution et donc la simulation
				puts("Fin de la simulation");break
			when 169 # On effectue un OU logique entre l'accumulateur et une constante
				abort(s+i.to_s) if(!mem[i+1]);acc |= mem[i+1];z = (acc == 0) ? 1:0;i += 2				
			when 254 # On effectue un OU logique entre l'accumulateur et une case mémoire
				abort(s+i.to_s) if(!mem[i+1]);acc |= mem[mem[i+1]];z = (acc == 0) ? 1:0;i += 2
			when 14 # On effectue un ET logique entre l'accumulateur et une constante
				abort(s+i.to_s) if(!mem[i+1]);acc &= mem[i+1];z = (acc == 0) ? 1:0;i += 2				
			when 35 # On effectue un ET logique entre l'accumulateur et une case mémoire
				abort(s+i.to_s) if(!mem[i+1]);acc &= mem[mem[i+1]];z = (acc == 0) ? 1:0;i += 2
			when 126 # On effectue ou OU EXCLUSIF entre l'accumulateur et une constante
				abort(s+i.to_s) if(!mem[i+1]);acc ^= mem[i+1];z = (acc == 0) ? 1:0;i += 2				
			when 28 # On effectue ou OU EXCLUSIF entre l'accumulateur et une case mémoire
				abort(s+i.to_s) if(!mem[i+1]);acc ^= mem[mem[i+1]];z = (acc == 0) ? 1:0;i += 2
			when 131 # on efface le drapeau de retenue
				r = 0;i += 1
			when 49 # on positionne le drapeau de retenue	
				r = 1;i += 1
			when 65 # On additionne une valeur immédiate à l'accumulateur avec le bit de retenue
				abort(s+i.to_s) if(!mem[i+1]);r2 = (acc + mem[i+1] + r >= BYTE_MAX) ? 1:0
				acc = (acc + mem[i+1] + r) % BYTE_MAX;r = r2;z = (acc == 0) ? 1:0;i += 2
			when 98 # On additionne une valeur en mémoire à l'accumulateur avec le bit de retenue
				abort(s+i.to_s) if(!mem[i+1]);r2 = (acc + mem[mem[i+1]] + r >= BYTE_MAX) ? 1:0
				acc = (acc + mem[mem[i+1]] + r) % BYTE_MAX;r = r2;z = (acc == 0) ? 1:0;i += 2				
			when 33 # On soustrait une valeur immédiate à l'accumulateur avec le complément de R
				abort(s+i.to_s) if(!mem[i+1]);r2 = (acc - (mem[i+1] + ((r == 0) ? 1:0)) >= 0) ? 1:0
				acc = (acc - (mem[i+1] + ((r == 0) ? 1:0))) % BYTE_MAX;r = r2;z = (acc == 0) ? 1:0
				i += 2
			when 66 # On soustrait une valeur en mémoire à l'accumulateur avec le complément de R
				abort(s+i.to_s) if(!mem[i+1]);r2=(acc - (mem[mem[i+1]] + ((r == 0) ? 1:0)) >= 0) ? 1:0
				acc = (acc - (mem[mem[i+1]] + ((r == 0) ? 1:0))) % BYTE_MAX;r = r2;z=(acc == 0) ? 1:0
				i += 2
			when 99 # On effectue un saut si le bit Z vaut 1 sinon on continue en séquence
				abort(s+i.to_s) if(!mem[i+1]);i = (z == 1) ? mem[i+1]:i+2
			when 101 # On effectue un saut si le bit Z vaut 0 sinon on continue en séquence
				abort(s+i.to_s) if(!mem[i+1]);i = (z == 0) ? mem[i+1]:i+2
			when 18 # On effectue un saut si le bit R vaut 1 sinon on continue en séquence
				abort(s+i.to_s) if(!mem[i+1]);i = (r == 1) ? mem[i+1]:i+2
			when 13 # On effectue un saut si le bit R vaut 0 sinon on continue en séquence
				abort(s+i.to_s) if(!mem[i+1]);i = (r == 0) ? mem[i+1]:i+2
			when 15 # On effectue un saut inconditionnel
				abort(s+i.to_s) if(!mem[i+1]);i = mem[i+1]
			when 45 # On décale le contenu de l'accumulateur vers la gauche
				r = acc >> 7;acc = (acc << 1) % BYTE_MAX;z = (acc == 0) ? 1:0;i += 1
			when 39 # On décale le contenu de la mémoire vers la gauche
				abort(s+i.to_s) if(!mem[i+1]);r = mem[mem[i+1]] >> 7
				mem[mem[i+1]] = (mem[mem[i+1]] << 1) % BYTE_MAX;z = (mem[mem[i+1]] == 0) ? 1:0;i += 2
			when 118 # On décale le contenu de l'accumulateur vers la droite
				r = acc & 1;acc >>= 1;z = (acc == 0) ? 1:0;i += 1
			when 12 # On décale le contenu de la mémoire vers la droite
				abort(s+i.to_s) if(!mem[i+1]);r = mem[mem[i+1]] & 1;mem[mem[i+1]] >>= 1
				z = (mem[mem[i+1]] == 0) ? 1:0;i += 2
			when 19 # On décale le contenu de l'accumulateur vers la gauche en insérant le bit R
				r2 = acc >> 7;acc = ((acc << 1) + r) % BYTE_MAX;z = (acc == 0) ? 1:0;r = r2;i += 1
			when 69 # On décale le contenu de la mémoire vers la gauche en insérant le bit R
				abort(s+i.to_s) if(!mem[i+1]);r2 = mem[mem[i+1]] >> 7
				mem[mem[i+1]] = ((mem[mem[i+1]] << 1) + r) % BYTE_MAX
				z = (mem[mem[i+1]] == 0) ? 1:0;r = r2;i += 2
			when 76 # On décale le contenu de l'accumulateur vers la droite en insérant le bit R
				r2 = acc & 1;acc = (acc >> 1) + (r << 7);z = (acc == 0) ? 1:0;r = r2;i += 1
			when 8 # On décale le contenu de la mémoire vers la droite en insérant le bit R
				abort(s+i.to_s) if(!mem[i+1]);r2 = mem[mem[i+1]] & 1
				mem[mem[i+1]]=(mem[mem[i+1]] >> 1)+(r << 7);z=(mem[mem[i+1]] == 0) ? 1:0;r=r2;i+= 2
			when 79 # On compare le contenu de l'accumulateur avec une valeur immédiate
				abort(s+i.to_s) if(!mem[i+1]);r = (acc - mem[i+1] >= 0) ? 1:0
				z = (acc - mem[i+1] == 0) ? 1:0;i+= 2
			when 80 # On compare le contenu de l'accumulateur avec une case mémoire
				abort(s+i.to_s) if(!mem[i+1]);r = (acc - mem[mem[i+1]] >= 0) ? 1:0
				z = (acc - mem[mem[i+1]] == 0) ? 1:0;i+= 2
			when 86 # On décrémente le contenu de la case mémoire
				abort(s+i.to_s) if(!mem[i+1]);mem[mem[i+1]] = (mem[mem[i+1]] - 1) % BYTE_MAX
				z = mem[mem[i+1]] == 0 ? 1:0;i+= 2				
			else
				abort("Instruction inconnue à l'adresse " + i.to_s) # code opération inconnu
		end
	end
	# On écrit le fichier mémoire résultat
	File.open(out, "w+") {|f| f.puts(mem)} rescue abort("Erreur lors de l'écriture de " + out)
end

# On vérifie la ligne de commande et on l'exécute
abort("Syntaxe : sim.rb <fichier entrée> <fichier sortie>") if ARGV.length != 2
simulate(ARGV[0],ARGV[1])