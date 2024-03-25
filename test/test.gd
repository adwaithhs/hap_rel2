extends RefCounted

class_name Test

func run():
	var radius = 0.5
	seed(162)
	var ch = Chromosome.random(radius, 25)
	ch.dissect(radius)
	
	pass

const OUT_IN = +1
const IN_IN = 0
const IN_OUT = -1

func test_inside():
	for dirs in [
		[IN_IN, IN_IN],
		[OUT_IN, IN_OUT, OUT_IN, IN_IN, IN_IN, IN_OUT],
		[],
		[OUT_IN, IN_IN],
		[IN_OUT, IN_IN],
		[OUT_IN, IN_OUT, IN_IN, IN_IN, IN_OUT],
		[OUT_IN, IN_OUT, OUT_IN, IN_IN, IN_IN],
		[OUT_IN, IN_OUT, IN_OUT, OUT_IN, IN_IN, IN_IN, IN_OUT],
		[IN_OUT, OUT_IN, IN_IN, IN_IN, IN_OUT],
		
	]:
		var ps = []
		for dir in dirs:
			ps.append({"dir":dir})
		
		print(GridNode.is_fine(ps))
