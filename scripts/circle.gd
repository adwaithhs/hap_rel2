extends RefCounted

class_name Circle

const TOL = Global.TOL

var center:= Vector2()

func _init(center: Vector2):
	self.center = center

func print():
	print({
		"c": center,
	})

func split(center: Vector2, radius:float, i: int) -> Array:
	var v = center-self.center
	var d = v.length()
	v = v.normalized()
	if d <= TOL:
		return []
	if d >= 2*radius - TOL:
		return []
	var th = acos(d / 2 / radius)
	
	var b1 = v.rotated(+th).angle()
	var b2 = v.rotated(-th).angle()
	
	var ret = []
	ret.append(PointData.new(self.center + radius * v.rotated(+th), i, center, PointData.OUT_IN))
	ret.append(PointData.new(self.center + radius * v.rotated(-th), i, center, PointData.IN_OUT))
	
	return ret


static func from(d):
	return Circle.new(d.c)
