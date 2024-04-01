extends Control

@export
var radius = 50

func _ready():
	pass

const PERIOD = 0.3
var time = 0.0
func _process(delta):
	time+=delta
	while time >= PERIOD:
		time -= PERIOD
	queue_redraw()

func _draw():
	var th = time / PERIOD * 2*PI
	draw_arc(Vector2(), radius, th, th+PI/2, 100, Color.AQUAMARINE, 4)
