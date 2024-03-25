extends RefCounted
class_name PointData

const OUT_IN = +1
const IN_IN = 0
const IN_OUT = -1

const NOT_V = -1
const V1 = 0
const V2 = 1

var p:= Vector2()
var i:= -1
var dir:= IN_OUT
var is_v:= NOT_V
var angle:= 0.0


func _init(p: Vector2, i: int, center: Vector2, dir:= IN_OUT, is_v:= NOT_V):
	self.p = p
	self.i = i
	self.dir = dir
	self.is_v = is_v
	self.angle = (p-center).angle()

