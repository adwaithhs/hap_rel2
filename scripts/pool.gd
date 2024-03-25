extends RefCounted

class_name Pool

signal chs_changed

var name:= ""
var radius:= 0.6
var min_dist:= 0.2
var chromosomes:= []

var mult_r:= 1.0
var mult_g:= 1.0


# no need to protect chromosomes
# subthread only use them before this
# main thread use them after this
func add(ch: Chromosome, mutex: Mutex):
	if ch.calc_score(radius, min_dist, mult_r, mult_g) == "error":
		var t = Time.get_unix_time_from_system()
		var file = FileAccess.open("res://saves/error_chs/"+str(t), FileAccess.WRITE)
		file.store_string(JSON.stringify(ch.to_dict(), "	"))
		return
	var chs = chromosomes
	var i = len(chs)
	var done = false
	while i > 0:
		i-=1
		if ch.score < chs[i].score:
			mutex.lock()
			chs.insert(i+1, ch)
			mutex.unlock()
			done = true
			break
	if not done:
		mutex.lock()
		chs.insert(0, ch)
		mutex.unlock()

func sort():
	chromosomes.sort_custom(func (a, b): return a.score > b.score)

func to_dict():
	var chs = []
	for ch in chromosomes:
		chs.append(ch.to_dict())
	return {
		"name": name,
		"radius": radius,
		"chromosomes": chs,
		"min_dist": min_dist,
		"mult_r": mult_r,
		"mult_g": mult_g,
	}

func to_dict2():
	return {
		"name": name,
		"radius": radius,
		"min_dist": min_dist,
		"mult_r": mult_r,
		"mult_g": mult_g,
	}

static func from_dict(d):
	var p = Pool.new()
	p.radius = d.radius
	for ch in d.chromosomes:
		p.chromosomes.append(Chromosome.from_dict(ch, p.radius, p.mult_r, p.mult_g))
	return p

func save():
	var file = FileAccess.open("res://saves/pools/"+name, FileAccess.WRITE)
	Global.mutex.lock()
	var d = to_dict()
	Global.mutex.unlock()
	file.store_string(JSON.stringify(d, "	"))
