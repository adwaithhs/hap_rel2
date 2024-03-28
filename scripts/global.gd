extends Node

const TOL = 1e-6

var pool: Pool
var i:= 1
var j:= 25
var main_scene

var save_after_step:= true
signal ch_changed

func _ready():
	var s = randi_range(0, 1000)
	print("seed: ", s)
	seed(s)

func set_i(k: int):
	if pool == null: return
	var n = len(pool.chs_dict[j])
	i = clamp(k, 1, n)
	ch_changed.emit()

func change_i(k: int, inf:= false):
	if pool == null: return
	var n = len(pool.chs_dict[j])
	if inf:
		if k > 0:
			i = n
		else:
			i = 1
	else:
		i = clamp(i + k, 1, n)
	ch_changed.emit()

func set_j(k: int):
	if pool == null: return
	var js = pool.chs_dict.keys()
	if len(js) == 0: return
	js.sort()
	var h = js.bsearch(k)
	if h >= len(js):
		h = len(js) - 1
	j = js[h]
	set_i(i)
	ch_changed.emit()

func change_j(k: int, inf:= false):
	if pool == null: return
	var js = pool.chs_dict.keys()
	if len(js) == 0: return
	js.sort()
	if inf:
		if k > 0:
			j = js[-1]
		else:
			j = js[0]
	else:
		var h = js.bsearch(j)
		if (h >= len(js) or js[h] != j) and k > 0:
			k -= 1 
		j = js[clamp(h+k, 0, len(js)-1)]
	change_i(0)
	ch_changed.emit()

func set_pool(p):
	pool = p
	main_scene.form.set_values(pool.to_dict2())
	ch_changed.emit()

func get_ch():
	if pool == null: return null
	if j not in pool.chs_dict: return null
	if i < 1: return null
	if i > len(pool.chs_dict[j]): return null
	return pool.chs_dict[j][i-1]

var debug:= false

func log(s: String):
	if debug:
		print(s)

func do_action(data: Dictionary):
	if data.key == "random":
		#var start = Time.get_ticks_msec()
		for i in data.n_chrms:
			var ch = Chromosome.random(pool.radius, data.n_gene)
			pool.add(ch)
		pool.sort()
	if data.key == "step":
		for i in data.n_steps:
			print("step: ", i)
			var chs1 = []
			for j in data.m_mut:
				for chs in pool.chs_dict.values():
					for ch1 in chs:
						var ch = ch1.mutate(pool.radius, data.p, data.q, data.dx, data.dw)
						chs1.append(ch)
			for ch in chs1:
				pool.add(ch)
			chs1 = []
			for chs in pool.chs_dict.values():
				chs1.append_array(chs)
			for j in data.n_cross:
				var h = randi_range(0, len(chs1) - 1)
				var k = randi_range(0, len(chs1) - 2)
				if k >= h:
					k += 1
				var ch1: Chromosome= chs1[h]
				var ch2: Chromosome= chs1[k]
				var ch = ch1.cross(ch2)
				pool.add(ch)
			pool.select(data.n_sel)
		pool.sort()
		if save_after_step:
			pool.save()
	
	change_j(0)
	ch_changed.emit()

#func _exit_tree():
	#mutex.lock()
	#exit_thread = true
	#mutex.unlock()
	#semaphore.post()
	#
	#thread.wait_to_finish()
