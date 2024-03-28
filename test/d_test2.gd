extends Node2D

const WIDTH = 4

@export
var size:= 150

var radius:= 0.6
var min_dist:= 0.2
var ch:= Chromosome.new()
var subset
var progress = -1

var i_set = 0

var i
var j

func _ready():
	#seed(162)
	#ch = Chromosome.random(radius, 25)
	var f = FileAccess.open("res://saves/pools/Pool1000", FileAccess.READ)
	var p = Pool.from_dict(JSON.parse_string(f.get_as_text()))
	ch = p.chs_dict[9][0]
	radius = p.radius
	min_dist = p.min_dist
	
	#var f = FileAccess.open("res://saves/error_chs/1710514705.29849", FileAccess.READ)
	#ch = Chromosome.from_dict1(JSON.parse_string(f.get_as_text()))
	
	#var i = 0
	#for c in [
		#Vector2(0.033197, -0.10739),
		#Vector2(-0.892373, -0.061342),
		#Vector2(0.088837, -0.743163),
	#]:
		#var g = Gene.new()
		#g.center = c
		#g.weight = i
		#i -= 1
		#ch.genes.append(g)
	pass

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_Z:
			progress = -1
			subset = null
			i_set = 0
			queue_redraw()
		if event.keycode == KEY_X:
			test_ch_step()
			queue_redraw()
		if event.keycode == KEY_S:
			progress = -1
			subset = null
			i_set = 0
			while progress < 22:
				test_ch_step()
			queue_redraw()
	
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var v = (event.position - position) / size
			v.y = -v.y
			if abs(v.x) > 1 or abs(v.y) > 1:
				return
			var n = ch.n
			if n == null:
				return
			var i = get_idx(n, v.x)
			var j = get_idx(n, v.y)
			if self.i == i and self.j == j:
				pass
			else:
				i_set = 0
				self.i = i
				self.j = j
			var node = ch.matrix[i][j]
			if len(node.subsets) < 1:
				return
			var s = 0.0
			for subset in node.subsets:
				s += subset.get_area(radius)
			print(s)
			subset = node.subsets[i_set]
			print("area: ", str(subset.get_area(radius)))
			i_set +=1
			if i_set >= len(node.subsets):
				i_set = 0
			queue_redraw()
			

func _draw():
	#draw_arc(Vector2(), size, 0, 2*PI, 10, Color.GREEN, 4)
	draw_square(size)
	for h in min(progress, len(ch.genes)):
		var g = ch.genes[h]
		if g.active:
			my_draw_circle(g.center*size, radius*size)
		else:
			my_draw_circle(g.center*size, radius*size, Color.MAGENTA)

	if subset == null:
		return
	print("------")
	for comp in subset.comps:
		print("comp")
		for e in comp:
			e.print()
			if e is Edge:
				draw_line(e.v1*size, e.v2*size, Color.GREEN, WIDTH/2)
			if e is Arc:
				var a1 = (e.v1 - e.center).angle()
				var a2 = (e.v2 - e.center).angle()
				if e.dir > 0:
					my_draw_arc(e.center*size, radius*size, e.v1*size, e.v2*size)
				else:
					my_draw_arc(e.center*size, radius*size, e.v2*size, e.v1*size)
			if e is Circle:
				my_draw_circle(e.center*size, radius*size, Color.GREEN)

func my_draw_arc(center: Vector2, radius: float, v1: Vector2, v2: Vector2, color:= Color.GREEN, width:= WIDTH):
	v1 = v1 - center
	v2 = v2 - center
	var th = v1.angle_to(v2)
	if th < 0:
		th+=2*PI
	var ps = []
	var n = 20
	for i in n+1:
		ps.append(center + v1.rotated(i*th/n))
	draw_polyline(ps, color, width)

func my_draw_circle(center: Vector2, radius: float, color:= Color.RED, width:= WIDTH):
	var ps = []
	var n = 20
	for i in n+1:
		ps.append(center + radius*Vector2.UP.rotated(2*PI*i/n))
	draw_polyline(ps, color, width)

func draw_square(a):
	var a00 = Vector2(-a, -a)
	var a10 = Vector2(a, -a)
	var a11 = Vector2(a, a)
	var a01 = Vector2(-a, a)
	for v in [
		[a00, a10],
		[a10, a11],
		[a11, a01],
		[a01, a00],
	]:
		draw_line(v[0], v[1], Color.BLUE, WIDTH)
	
	draw_line(Vector2(2*a, 0), Vector2(-2*a, 0), Color.BLUE, WIDTH/2)
	draw_line(Vector2(0, 2*a), Vector2(0, -2*a), Color.BLUE, WIDTH/2)
	
func test_ch_step():
	if progress >= len(ch.genes):
		print("Done")
		progress = -1
		subset = null
		i_set = 0
		return
	if progress == -1:
		ch.init_matrix(radius)
		progress+=1
		subset = null
		return
	print("progress: ", progress)
	var g = ch.genes[progress]
	g.active = false
	print(g.center)
	var flag = false
	for j in progress:
		if (g.center - ch.genes[j].center).length() < min_dist:
			flag = true
			break
	if flag:
		progress+=1
		subset = null
		return
	var nbhood = ch.get_nbhd(g)
	var needed = false
	for node in nbhood:
		var ret = node.slice(g, radius)
		if ret is String and ret == "error":
			print("error")
		elif ret:
			needed = true
	if needed:
		g.active = true
		for node in nbhood:
			node.subsets = node.newsubs
	for node in nbhood:
		node.newsubs = []
	progress+=1
	subset = null


func get_idx(n: int, x: float):
	var i = floor((x + 1.0) / 2 * n) + 1
	return clamp(i, 0, n+1)
