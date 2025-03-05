# Donne un exemple de hasard tout à fait prévisible !

def hasard(graine,n,periode)
	for i in graine...graine + n
		puts (i%periode).to_s
	end
end

hasard(2456897555,10,2**32)
