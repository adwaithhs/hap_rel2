extends RefCounted

class_name Arc

const TOL = Global.TOL

var center:= Vector2()
var v1:= Vector2()
var v2:= Vector2()
var dir:= 1

func _init(center: Vector2, v1: Vector2, v2: Vector2, dir:=1):
	self.center = center
	self.v1 = v1
	self.v2 = v2
	self.dir = dir

func print():
	print({
		"c": center,
		"v1": v1,
		"v2": v2,
		"dir": dir,
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
	
	if dir < 0:
		var temp = b1
		b1 = b2
		b2 = temp
		th = -th
	
	var ret = []
	var u
	
	u = self.center + radius * v.rotated(+th)
	if (u - v1).length() < TOL:
		ret.append(PointData.new(u, i, center, PointData.OUT_IN, PointData.V1))
	elif (u - v2).length() < TOL:
		ret.append(PointData.new(u, i, center, PointData.OUT_IN, PointData.V2))
	elif is_inside(b1):
		ret.append(PointData.new(u, i, center, PointData.OUT_IN))
	
	u = self.center + radius * v.rotated(-th)
	if (u - v1).length() < TOL:
		ret.append(PointData.new(u, i, center, PointData.IN_OUT, PointData.V1))
	elif (u - v2).length() < TOL:
		ret.append(PointData.new(u, i, center, PointData.IN_OUT, PointData.V2))
	elif is_inside(b2):
		ret.append(PointData.new(u, i, center, PointData.IN_OUT))
	
	
	return ret

func is_inside(b: float):
	var a1 = (v1 - center).angle()
	var a2 = (v2 - center).angle()
	if dir < 0:
		var temp = a1
		a1 = a2
		a2 = temp
	if a2 < a1:
		return b > a1 or b < a2
	else:
		return b > a1 and b < a2


static func from(d):
	return Arc.new(d.c, d.v1, d.v2, d.dir)
