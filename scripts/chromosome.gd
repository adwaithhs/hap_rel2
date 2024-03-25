extends RefCounted

class_name Chromosome

var genes:= []
var score = null
var matrix
var n
var distn = {}

func to_dict():
	var gs = []
	for gene in genes:
		gs.append(gene.to_dict())
	return{
		"genes": gs,
		"distn": distn
	}

static func from_dict1(d):
	var ch = Chromosome.new()
	ch.distn = d.distn
	for g in d.genes:
		ch.genes.append(Gene.from_dict(g))
	return ch

static func from_dict(d, radius:=0.6, mult_r:=1.0, mult_g:=1.0):
	var ch = Chromosome.new()
	for g in d.genes:
		ch.genes.append(Gene.from_dict(g))
	ch.distn = d.distn
	ch.get_score_from_distn(mult_r, mult_g)
	return ch

static func random(radius, n_genes) -> Chromosome:
	var child = Chromosome.new()
	for i in n_genes:
		var g = Gene.new()
		g.center.x = (1+radius)*randz()
		g.center.y = (1+radius)*randz()
		g.weight = randfn(0.0, 1.0)
		child.genes.append(g)
	return child

func mutate(radius, p, q, dx, dw) -> Chromosome:
	var child = Chromosome.new()
	for gene in genes:
		var g = gene.copy()
		if randf() < p:
			g.center.x = wrapf(
				gene.center.x + dx*randz(),
				-1-radius,
				+1+radius,
			)
			g.center.y = wrapf(
				gene.center.y + dx*randz(),
				-1-radius,
				+1+radius,
			)
		if randf() < q:
			g.weight += randfn(0.0, dw)
			g.weight /= sqrt(1.0 + dw*dw)
		child.genes.append(g)
	return child

func cross(ch1) -> Chromosome:
	var child = Chromosome.new()
	var th = randf_range(0, 2*PI)
	var dir = Vector2.RIGHT.rotated(th)
	var gs1 = genes
	var gs2 = ch1.genes
	if len(gs1) < len(gs2):
		var temp = gs1
		gs1 = gs2
		gs2 = temp
	if len(gs1) != len(gs2):
		var gg = []
		gg.resize(len(gs1))
		for i in len(gs1):
			gg[i] = i
		gg.shuffle()
		var ngs = []
		for i in len(gs1):
			if gg[i] < len(gs2):
				ngs.append(gs1[i])
		gs1 = ngs
	else:
		gs1 = gs1.duplicate()
	gs2 = gs2.duplicate()
	var callable = func(a, b): return dir.dot(a.center) > dir.dot(b.center)
	gs1.sort_custom(callable)
	gs2.sort_custom(callable)
	for i in len(gs2):
		if randf() < 0.5:
			child.genes.append(gs1[i].copy())
		else:
			child.genes.append(gs2[i].copy())
	return child

static func randz():
	return 2*randf() - 1

var score_r = 0
var cost_g = 0

func calc_distn(radius: float):
	distn = {}
	for l in matrix:
		for node in l:
			for sset in node.subsets:
				var n = len(sset.genes)
				if n not in distn:
					distn[n] = 0.0
				distn[n] += sset.get_area(radius)

func get_score_from_distn(mult_r:= 1.0, mult_g:= 1.0):
	var mtbf_area = 0.0
	var mtbf_getter = MTBFGetter.new()
	var total_area = 0.0
	for n in distn:
		var area = distn[n]
		mtbf_area += mtbf_getter.get_mtbf(n) * area
		total_area += area
	if abs(total_area - 4.0) > 1e-6:
		print("error in total area: ", total_area)
	
	var gene_cost = 0
	for gene in genes:
		if gene.active:
			gene_cost+=1
	
	score_r = mtbf_area / total_area * mult_r
	cost_g = gene_cost * mult_g
	score = score_r - cost_g

func calc_score(radius: float, min_dist: float, mult_r:= 1.0, mult_g:= 1.0):
	var ret = dissect(radius, min_dist)
	if ret is String and ret == "error":
		return "error"
	
	calc_distn(radius)
	get_score_from_distn(mult_r, mult_g)
	matrix = null

func init_matrix(radius: float):
	genes.sort_custom(func(a, b): return a.weight > b.weight)
	n = floor(2.0 / radius)
	matrix = []
	matrix.resize(n+2)
	for i in n+2:
		var l = []
		l.resize(n+2)
		for j in n+2:
			l[j] = GridNode.new()
			l[j].pos = Vector2i(i, j)
		matrix[i] = l
	for h in len(genes):
		var g = genes[h]
		var i = get_index(n, g.center.x)
		var j = get_index(n, g.center.y)
		matrix[i][j].genes.append(g)
		g.pos = Vector2i(i, j)
	for i in range(1, n+1):
		for j in range(1, n+1):
			matrix[i][j].init(n)

func get_index(n: int, x: float):
	var i = floor((x + 1.0) / 2 * n) + 1
	return clamp(i, 0, n+1)

func get_nbhd(g: Gene):
	var nbhood:= []
	for i in range(
		clampi(g.pos.x - 1, 1, n),
		clampi(g.pos.x + 1, 1, n) + 1
	):
		for j in range(
			clampi(g.pos.y - 1, 1, n),
			clampi(g.pos.y + 1, 1, n) + 1,
		):
			var node = matrix[i][j]
			if true: # TODO intersect(node, gene) != phi:
				nbhood.append(node)
	return nbhood

func dissect(radius: float, min_dist: float):
	init_matrix(radius)
	for i in len(genes):
		var g = genes[i]
		g.active = false
		var flag = false
		for  j in i:
			if (g.center - genes[j].center).length() < min_dist:
				flag = true
				break
		if flag:
			continue
		var nbhood = get_nbhd(g)
		var needed = false
		for node in nbhood:
			var ret = node.slice(g, radius)
			if ret is String and ret == "error":
				return "error"
			if ret:
				needed = true
		if needed:
			g.active = true
			for node in nbhood:
				node.subsets = node.newsubs
		for node in nbhood:
			node.newsubs = []

