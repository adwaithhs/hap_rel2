extends Node

const TOL = 1e-6

var pool: Pool
var i:= 1
var main_scene

var mutex: Mutex
var semaphore: Semaphore
var thread: Thread
var exit_thread := false
var dirty:= true

var post_data
var save_after_step:= true
signal ch_changed

func _ready():
	var s = randi_range(0, 1000)
	print("seed: ", s)
	seed(s)
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	exit_thread = false

	thread = Thread.new()
	thread.start(_thread_func, Thread.PRIORITY_HIGH)
	

func set_i(j:int, end:= false):
	if pool == null: return
	mutex.lock()
	var n = len(pool.chromosomes)
	mutex.unlock()
	if end:
		j = n - j + 1
	i = clamp(j, 1, n)

func set_pool(p):
	pool = p
	main_scene.form.set_values(pool.to_dict2())
	#do_action({
		#"key": "random",
		#"n_chrms": 100,
		#"n_gene": 25,
	#})

func get_ch():
	if pool == null: return null
	mutex.lock()
	var chs = pool.chromosomes
	mutex.unlock()
	if i < 1: return null
	if i > len(chs): return null
	return chs[i-1]

var debug:= false

func log(s: String):
	if debug:
		print(s)

const SIGNAL_PERIOD = 0.1
var time:= 0.0
func _process(delta):
	time += delta
	if time >= SIGNAL_PERIOD:
		time -= SIGNAL_PERIOD
	else:
		return
	mutex.lock()
	var d = dirty
	mutex.unlock()
	if d:
		if main_scene:
			main_scene.index_input.refresh()
		set_i(i)
		ch_changed.emit()

func _thread_func():
	while true:
		semaphore.wait() # Wait until posted.
		#mutex.lock()
		#var should_exit = exit_thread
		#mutex.unlock()
		#if should_exit: break
		
		var data
		mutex.lock()
		if post_data != null:
			data = post_data.duplicate()
		mutex.unlock()
		
		if data != null:
			do_action(data)
		
		mutex.lock()
		post_data = null
		mutex.unlock()

func post(data: Dictionary) -> bool:
	var flag = false
	mutex.lock()
	if post_data == null:
		post_data = data.duplicate()
		flag = true
	mutex.unlock()
	if flag:
		semaphore.post()
	return flag

func do_action(data: Dictionary):
	if data.key == "random":
		#var start = Time.get_ticks_msec()
		for i in data.n_chrms:
			var ch = Chromosome.random(pool.radius, data.n_gene)
			pool.add(ch, mutex)
			mutex.lock()
			dirty = true
			mutex.unlock()
		#var stop = Time.get_ticks_msec()
		#print(stop - start)
	if data.key == "step":
		#mutex.lock()
		#var n = len(pool.chromosomes)
		#mutex.unlock()
		for i in data.n_steps:
			print("step: ", i)
			var chs = pool.chromosomes.duplicate()
			var n = len(chs)
			for j in data.m_mut:
				for ch1 in chs:
					var ch = ch1.mutate(pool.radius, data.p, data.q, data.dx, data.dw)
					pool.add(ch, mutex)
					mutex.lock()
					dirty = true
					mutex.unlock()
			chs = pool.chromosomes.duplicate()
			for j in data.m_cross * n:
				var h = randi_range(0, len(chs) - 1)
				var k = randi_range(0, len(chs) - 2)
				if k >= h:
					k += 1
				var ch1: Chromosome= chs[h]
				var ch2: Chromosome= chs[k]
				var ch = ch1.cross(ch2)
				pool.add(ch, mutex)
				mutex.lock()
				dirty = true
				mutex.unlock()
			mutex.lock()
			pool.chromosomes.resize(data.n_sel)
			dirty = true
			mutex.unlock()
		if save_after_step:
			pool.save()

#func _exit_tree():
	#mutex.lock()
	#exit_thread = true
	#mutex.unlock()
	#semaphore.post()
	#
	#thread.wait_to_finish()
