extends RefCounted

class_name Pool

signal chs_changed

var name:= ""
var radius:= 0.6
var min_dist:= 0.2
var rel:= 0.99
var chs_dict:= {}


func add(ch: Chromosome):
	if ch.calc_score(radius, min_dist, rel) == "error":
		var t = Time.get_unix_time_from_system()
		var file = FileAccess.open("res://saves/error_chs/"+str(t), FileAccess.WRITE)
		file.store_string(JSON.stringify(ch.to_dict(), "	"))
		return
	var n = ch.cost_g
	if n not in chs_dict:
		chs_dict[n] = []
	var chs = chs_dict[n]
	chs.append(ch)


func sort():
	for chs in chs_dict.values():
		chs.sort_custom(func (a, b): return a.score_r > b.score_r)

func select(n: int):
	for chs in chs_dict.values():
		if len(chs) > n:
			chs.resize(n)
	pass

func to_dict():
	var chs_d = {}
	for i in chs_dict:
		var chs = []
		for ch in chs_dict[i]:
			chs.append(ch.to_dict())
		chs_d[i] = chs
	return {
		"name": name,
		"radius": radius,
		"min_dist": min_dist,
		"rel": rel,
		"chs_dict": chs_d,
	}

func to_dict2():
	return {
		"name": name,
		"radius": radius,
		"min_dist": min_dist,
		"rel": rel,
	}

static func from_dict(d):
	var p = Pool.new()
	p.name = d.name
	p.radius = d.radius
	p.min_dist = d.min_dist
	p.rel = d.rel
	for j in d.chs_dict:
		var chs = d.chs_dict[j]
		p.chs_dict[int(j)] = []
		for ch in chs:
			p.chs_dict[int(j)].append(Chromosome.from_dict(ch, p.rel))
	return p

func save():
	var file = FileAccess.open("res://saves/pools/"+name, FileAccess.WRITE)
	file.store_string(JSON.stringify(to_dict(), "	"))
