extends RefCounted

class_name Subset

var comps:= []
var genes:= []

func get_fail(f:=0.9):
	return pow(f, len(genes))

func get_mult():
	return len(genes)

func get_area(radius: float):
	
	var area = 0
	for comp in comps:
		var ps: Array[Vector2] = []
		for edge in comp:
			if edge is Circle:
				area +=  PI * radius * radius
				break
			ps.append(edge.v1)
			if edge is Arc:
				var th = (edge.v1 - edge.center).angle_to(edge.v2 - edge.center)
				th = abs(th)
				var a1 = (th - sin(th)) / 2 * radius * radius
				area += sign(edge.dir) * a1
		
		if len(ps) % 2 != 0:
			ps.append(ps[0])
		var a = 0.0
		for i in range(0, len(ps), 2):
			var i1 = wrap(i+1, 0, len(ps))
			var i2 = wrap(i+2, 0, len(ps))
			a += ps[i1].x*(ps[i2].y - ps[i].y) + ps[i1].y *(ps[i].x - ps[i2].x)
		a /= 2
		area += a
	
	return area
