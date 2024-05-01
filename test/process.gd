extends Control

const DEF_POOL = {
	"name": "POOL",
	"radius": 0.6,
	"min_dist": 0.2,
	"rel": 0.99,
}

func _ready():
	for rel in [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.99]:
		do_for(rel)

func do_for(rel):
	var p = Pool.new()
	p.name = "PoolA" + str(rel)
	p.radius = 0.6
	p.min_dist = 0.2
	p.rel = rel
	var path = "res://saves/pools/"
	for f in DirAccess.get_files_at(path):
		var file = FileAccess.open(path+f, FileAccess.READ)
		var d = JSON.parse_string(file.get_as_text())
		if d == null:
			continue
		var flag = false
		for k in DEF_POOL:
			if k not in d:
				flag = true
		if flag:
			continue
		if d.radius != p.radius: continue
		if d.min_dist != p.min_dist: continue
		for j in d.chs_dict:
			var chs = d.chs_dict[j]
			for ch in chs:
				var c = Chromosome.from_dict1(ch)
				p.add(c)
	p.select(5)
	p.save()
	
