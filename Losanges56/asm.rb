MEM_SIZE = 256 # taille de la mémoire
Instruction = Struct.new(:name, :imm, :opcode, :value_exists, :size)
# Table listant toutes les directives et codes opérations avec leurs propriétés :
# nom, existence d'un mode immédiat, valeur du code opération, présence d'une valeur et taille
$inst_table = [
	Instruction.new("ADRESSE",	false,	-1,	true,	0),	# par exemple ADRESSE 128
	Instruction.new("VAL",		false,	-1,	true,	1),	# par exemple VAL 25
	Instruction.new("ECRISA",	false,	1,	true,	2),	# par exemple ECRISA 10
	Instruction.new("CHARGEA",	true,	2,	true,	2),	# par exemple CHARGEA #12
	Instruction.new("CHARGEA",	false,	3,	true,	2),	# par exemple CHARGEA 12
	Instruction.new("ADDA",		true,	4,	true,	2),	# par exemple ADDA #24
	Instruction.new("ADDA",		false,	5,	true,	2),	# par exemple ADDA 24
	Instruction.new("STOP",		false,	6,	false,	1),	# STOP
	Instruction.new("OUA",		true,	169,true,	2),	# par exemple OUA #200
	Instruction.new("OUA",		false,	254,true,	2),	# par exemple OUA 132
	Instruction.new("ETA",		true,	14,	true,	2),	# par exemple ETA #200
	Instruction.new("ETA",		false,	35,	true,	2),	# par exemple ETA 132
	Instruction.new("OUEXA",	true,	126,true,	2),	# par exemple OUEXA #200
	Instruction.new("OUEXA",	false,	28,	true,	2),	# par exemple OUEXA 132
	Instruction.new("EFFR",		false,	131,false,	1),	# EFFR
	Instruction.new("POSR",		false,	49,	false,	1),	# POSR
	Instruction.new("ADDAR",	true,	65,	true,	2),	# par exemple ADDAR #24
	Instruction.new("ADDAR",	false,	98,	true,	2),	# par exemple ADDAR 24
	Instruction.new("SOUSAR",	true,	33,	true,	2),	# par exemple SOUSAR #24
	Instruction.new("SOUSAR",	false,	66,	true,	2),	# par exemple SOUSAR 24	
	Instruction.new("SAUTZ",	false,	99,	true,	2),	# par exemple SAUTZ 134
	Instruction.new("SAUTNZ",	false,	101,true,	2),	# par exemple SAUTNZ 134	
	Instruction.new("SAUTR",	false,	18,	true,	2),	# par exemple SAUTR 134
	Instruction.new("SAUTNR",	false,	13,	true,	2),	# par exemple SAUTNR 134
	Instruction.new("SAUT",		false,	15,	true,	2),	# par exemple SAUT 134
	Instruction.new("DECG",		false,	45,	false,	1),	# par exemple DECG
	Instruction.new("DECG",		false,	39,	true,	2),	# par exemple DECG 28
	Instruction.new("DECD",		false,	118,false,	1),	# par exemple DECD
	Instruction.new("DECD",		false,	12,	true,	2),	# par exemple DECD 29
	Instruction.new("ROTG",		false,	19,	false,	1),	# par exemple ROTG
	Instruction.new("ROTG",		false,	69,	true,	2),	# par exemple ROTG 30
	Instruction.new("ROTD",		false,	76,	false,	1),	# par exemple ROTD
	Instruction.new("ROTD",		false,	8,	true,	2),	# par exemple ROTD 31
	Instruction.new("COMPA",	true,	79,	true,	2),	# par exemple COMPA #31
	Instruction.new("COMPA",	false,	80,	true,	2),	# par exemple COMPA 65
	Instruction.new("DEC",		false,	86,	true,	2),	# par exemple DEC 25
]

def assemble(source,dest) # point d'entrée
	# On lit le contenu du fichier assembleur
	file = File.open(source) rescue abort("Impossible d'ouvrir le fichier " + source)
	text = file.read
	labels = Hash.new # pour stocker les labels
	# On parcourt le fichier deux fois :
	# une première pour repérer les labels et une seconde pour l'assemblage
	for pass in 1..2
		cur = -1 # adresse d'assemblage courante
		num = 0 # numéro de ligne courant
		mem = Array.new(MEM_SIZE,0) # on remplit la mémoire avec des zéros
		text.each_line do |line| # on analyse le fichier assembleur ligne par ligne
			num += 1 # on incrémente le numéro de ligne
			line = line.split(";")[0] # on ignore les commentaires
			line = line.chomp.strip # on enlève retours chariots et espaces de début et de fin
			next if line.to_s == '' # on ignore les éventuelles lignes vides
			# On éclate la ligne, pour séparer le code opération de son opérande éventuel
			elems = line.gsub(/\s+/m, ' ').strip.split(" ")

			# Analyse de la ligne (avec vérifications)
			imm = false # par défaut, pas de mode d'adressage immédiat
			value_exists = elems[1] ? true:false; # valeur ou opérande présent ?
			if(value_exists) then
				imm = (elems[1][0] == "#") ? true:false # si croisillon alors le mode est immédiat				
				value = imm ? elems[1][1..-1]:elems[1] # si immédiat, on enlève le croisillon

				# On fait la distinction entre les deux passes
				if(pass == 1) then
					value = value.to_i # si c'est une référence à un label, value vaudra 0
				else
					# On est dans la seconde passe : on commence par regarder s'il s'agit d'un label
					if(labels.key?(value)) then
						value = labels[value] # c'est le cas
					else
						value = value.to_i rescue abort("Valeur ou opérande invalide en ligne " + num.to_s)
					end
				end
				
				abort("Valeur ou opérande invalide en ligne " + num.to_s) if(value < 0 || value > 255)
			else
				# On regarde si c'est un label si on est dans la première passe
				if(elems[0][-1] == ":") then 
					if(pass == 1) then
						# C'est un label : on vérifie qu'il n'existe pas déjà
						abort("Label en doublon en ligne " + num.to_s) if(labels.key?(elems[0][0...-1])) 
						abort("Adresse non définie en ligne " + num.to_s) if(cur == -1) # adresse inconnue
						labels.store(elems[0][0...-1],cur) # on mémorise le label
					end
					next # on reboucle ligne suivante pour les deux passes
				end
			end

			# Recherche de l'instruction correspondante dans la table
			inst_found = false
			$inst_table.each do |inst| # on boucle sur la table
				if(elems[0].eql? inst.name and imm == inst.imm and value_exists == inst.value_exists)
					# On a trouvé l'instruction : on vérifie s'il reste de la place en mémoire					
					abort("Plus de place en mémoire en ligne "+num.to_s) if(cur + inst.size >= MEM_SIZE)
					inst_found = true
					# Cas particulier de ADRESSE et VAL
					begin cur = value; inst_found = true; break end if(inst.name.eql? "ADRESSE") 	
					abort("Adresse non définie en ligne " + num.to_s) if(cur == -1) # adresse inconnue					
					begin mem[cur] = value; cur += 1;inst_found = true;break end if(inst.name.eql? "VAL")
					# Autres instructions
					mem[cur] = inst.opcode # écriture du code opération en mémoire
					cur += 1 # on avance dans la mémoire (on a écrit un octet)
					begin mem[cur] = value; cur += 1 end if(inst.value_exists) # écriture de la valeur
				end
			end			
			abort("Erreur de syntaxe en ligne "+num.to_s) if(!inst_found) # non trouvé dans la table
		end
	end
	# On sauvegarde le résultat
	File.open(dest, "w+") {|f| f.puts(mem)} rescue abort("Erreur lors de l'écriture de " + dest)
end
# On vérifie la ligne de commande et on appelle le point d'entrée 
abort("Syntaxe : asm.rb <fichier assembleur> <fichier résultat>") if ARGV.length != 2
assemble(ARGV[0],ARGV[1])