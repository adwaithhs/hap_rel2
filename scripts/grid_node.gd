extends RefCounted

class_name GridNode

const TOL = Global.TOL

const OUT_IN = PointData.OUT_IN
const IN_IN = PointData.IN_IN
const IN_OUT = PointData.IN_OUT

var pos:= Vector2i()
var genes:= []
var area:= []
var subsets:= []
var newsubs:= []
var covered:= false

func init(n):
	var i = pos.x
	var j = pos.y
	
	var a00 = Vector2(i-1, j-1)*2/n + Vector2(-1, -1)
	var a10 = Vector2(i, j-1)*2/n + Vector2(-1, -1)
	var a11 = Vector2(i, j)*2/n + Vector2(-1, -1)
	var a01 = Vector2(i-1, j)*2/n + Vector2(-1, -1)
	area = [
		Edge.new(a00, a10),
		Edge.new(a10, a11),
		Edge.new(a11, a01),
		Edge.new(a01, a00),
	]
	var s = Subset.new()
	s.comps.append(area)
	subsets.append(s)

func slice(g: Gene, radius: float):
	var center = g.center
	newsubs = []
	var needed = false
	for f in len(subsets):
		var sset = subsets[f]
		var int_comps = []
		var ext_comps = []
		
		for h in len(sset.comps):
			var comp = sset.comps[h]
			var ps:= []
			for i in len(comp):
				var edge = comp[i]
				var arr = edge.split(center, radius, i)
				ps.append_array(arr)
			
			ps.sort_custom(func (a, b): return a.angle < b.angle)
			#print("pos: ", pos)
			#print("f: ", f)
			#print("h: ", h)
			#print("comp----")
			#for e in comp:
				#e.print()
			
			#print("st------")
			#var st = ""
			#for p in ps:
				#st += str(p.i) + " "
			#print(st)
			ps = merge_points(ps, comp)
			#st = ""
			#for p in ps:
				#st += str(p.i) + " "
			#print(st)
			if len(ps) == 0:
				if is_circle_outside(comp, center, radius):
					ext_comps.append(comp)
				else:
					int_comps.append(comp)
				continue
			if not is_fine(ps):
				var s = ""
				for p in ps:
					s += str(p.dir) + " "
				print("error is_fine == false")
				print(s)
				return "error"
			var k:= -1
			for i in len(ps):
				var p = ps[i]
				if p.dir == OUT_IN:
					k = i
					break
			var compi = []
			var compes = []
			#print("k: ", k)
			if k == -1: # only IN_IN, only when radius = 1
				for i in len(ps):
					var u1 = ps[i-1]
					var u2 = ps[i]
					var dir = u2.dir
					if dir != IN_IN:
						print("error impossible")
						return "error"
					var compe = [Arc.new(center, u2.p, u1.p, -1)]
					var x = get_b(comp, u1, u2)
					compe.append_array(x)
					compes.append(compe)
						
				compi.append(Circle.new(center))
				int_comps.append(compi)
				ext_comps.append_array(compes)
				continue
			var v1
			var v2
			var u1
			var u2
			for i in range(k - len(ps), k):
				var pd = ps[i]
				var dir = pd.dir
				if dir == OUT_IN:
					v1 = pd
					u1 = pd
					if v2 != null:
						var x = get_b(comp, v2, v1)
						compi.append_array(x)
				else:
					u2 = pd
					var compe = [Arc.new(center, u2.p, u1.p, -1)]
					var x = get_b(comp, u1, u2)
					compe.append_array(x)
					compes.append(compe)
				if dir == IN_IN:
					u1 = u2
				if dir == IN_OUT:
					v2 = pd
					compi.append(Arc.new(center, v1.p, v2.p, 1))
			if v2 == null:
				return "error"
			var x = get_b(comp, v2, ps[k])
			compi.append_array(x)
			int_comps.append(compi)
			ext_comps.append_array(compes)
		
		if len(int_comps) != 0:
			var s = Subset.new()
			s.comps = int_comps
			s.genes = sset.genes.duplicate()
			if len(sset.genes) < 2:
				needed = true
			s.genes.append(g)
			newsubs.append(s)
			
		if len(ext_comps) != 0:
			var s = Subset.new()
			s.comps = ext_comps
			s.genes = sset.genes.duplicate()
			newsubs.append(s)
	
	return needed

func is_circle_outside(comp, center, radius):
	for edge in comp:
		var vs
		if edge is Circle:
			vs = [edge.center]
		else:
			vs = [edge.v1, edge.v2]
		for v in vs:
			var d = (v - center).length()
			if d <= radius - TOL:
				return false
			if d >= radius + TOL:
				return true
	return false

func get_b(comp: Array, p1: PointData, p2: PointData):
	var i = p1.i
	var j = p2.i
	var ret = []
	
	if i == j:
		var edge = comp[i]
		
		if edge is Edge:
			if (p1.p - edge.v1).length() < (p2.p - edge.v1).length():
				return [Edge.new(p1.p, p2.p)]
		if edge is Arc:
			var h1 = p1.p - edge.center
			var h2 = p2.p - edge.center
			var g1 = edge.v1 - edge.center
			var g2 = edge.v2 - edge.center
			var a1 = sign(edge.dir)*g1.angle_to(h1)
			var a2 = sign(edge.dir)*g1.angle_to(h2)
			if a1 < 0:
				a1 += PI
			if a2 < 0:
				a2 += PI
			if a1 < a2:
				return [Arc.new(edge.center, p1.p, p2.p, edge.dir)]
		
		if edge is Circle:
			return [Arc.new(edge.center, p1.p, p2.p)]
	
	var u1 = p1.p
	var edge = comp[i]
	
	if (u1-edge.v1).length() <= TOL:
		ret.append(edge)
	elif (u1-edge.v2).length() < TOL:
		pass
	else:
		if edge is Edge:
			ret.append(Edge.new(u1, edge.v2))
		if edge is Arc:
			ret.append(Arc.new(edge.center, u1, edge.v2, edge.dir))
	
	var n = len(comp) if i>=j  else 0
	for k in range(i+1 - n, j):
		ret.append(comp[k])
	
	var u2 = p2.p
	edge = comp[j]
	
	if (u1-edge.v1).length() <= TOL:
		pass
	elif (u1-edge.v2).length() < TOL:
		ret.append(edge)
	else:
		if edge is Edge:
			ret.append(Edge.new(edge.v1, u2))
		if edge is Arc:
			ret.append(Arc.new(edge.center, edge.v1, u2, edge.dir))
	
	return ret

func merge_points_old(ps: Array):
	var ret = []
	if len(ps) <= 1:
		return ps
	var is_all_same = true
	for i in len(ps):
		if (
			(ps[i].p - ps[i-1].p).length() < 2*TOL and 
			ps[i].dir == ps[i-1].dir
		):
			pass
		else:
			is_all_same = false
			ret.append(ps[i])
	if is_all_same:
		return [ps[0]]
	return ret

func merge_points(ps: Array, comp: Array):
	var ret = []
	if len(ps) <= 1:
		return ps
	var is_all_same = true
	for i in len(ps):
		var p1 = ps[i]
		var p2 = ps[i-1]
		if (
			(p1.p - p2.p).length() < 2*TOL and
			p1.is_v != PointData.NOT_V and
			p2.is_v != PointData.NOT_V and
			p1.dir == p2.dir
		):
			pass
		else:
			is_all_same = false
			ret.append(ps[i])
	if is_all_same:
		return [ps[0]]
	return ret

static func is_fine(ps):
	if len(ps) == 0: return true
	var inside: bool= ps[0].dir != OUT_IN
	for p in ps:
		if p.dir == IN_IN:
			if not inside:
				return false
			inside = true
		if p.dir == IN_OUT:
			if not inside:
				return false
			inside = false
		if p.dir == OUT_IN:
			if inside:
				return false
			inside = true
	if ps[0].dir == OUT_IN:
		if inside: return false
	else:
		if not inside: return false
	
	return true
	


