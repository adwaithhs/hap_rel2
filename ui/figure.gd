extends Node2D

const WIDTH = 4

@export
var size:= 150

func _draw():
	draw_square(size)
	var pool = Global.pool
	var ch = Global.get_ch()
	if ch == null:
		return
	for g in ch.genes:
		if g.active:
			draw_arc(g.center*size, pool.radius*size, 0, 2*PI, 100, Color.RED, WIDTH)

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
	
