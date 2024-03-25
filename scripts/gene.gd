extends RefCounted

class_name Gene

var center:= Vector2()
var weight:= 0.0
var active:= false
var pos:= Vector2i()
var i:= -1

func copy():
	var g = Gene.new()
	g.center = center
	g.weight = weight
	return g

func to_dict():
	return {
		"center": [center.x, center.y],
		"weight": weight,
		"active": active,
	}

static func from_dict(d):
	var g = Gene.new()
	g.center = Vector2(d.center[0], d.center[1])
	g.weight = d.weight
	g.active = d.active
	return g

func print():
	print({
		"c": center,
		"w": weight,
	})
