extends RefCounted

class_name MTBFGetter

var cache: PackedFloat64Array= [0, 1, 2.5]

func get_mtbf(m: int):
	if m <= 0: return 0
	if len(cache) <= m:
		cache.resize(m+1)
	if cache[m] == 0:
		var ret = 0
		for i in range(1, m+1):
			var f = 1
			for j in i:
				f *= m-j
			for j in i:
				f /= j+1
			f /= float(i)
			ret+=f
		cache[m] = ret
	return cache[m]
