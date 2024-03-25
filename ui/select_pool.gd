extends Control

const DEF_POOL = {
	"name": "POOL",
	"radius": 0.6,
	"min_dist": 0.2,
	"mult_r": 2.0,
	"mult_g": 3.0,
}

@onready
var item_list = $MarginContainer/VBoxContainer/ItemList
@onready
var form = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/Form

var pools = []

func _ready():
	refresh()

func refresh():
	item_list.clear()
	item_list.add_item("---New Pool---")
	item_list.select(0)
	var path = "res://saves/pools/"
	pools = []
	for f in DirAccess.get_files_at(path):
		var file = FileAccess.open(path+f, FileAccess.READ)
		var d = JSON.parse_string(file.get_as_text())
		if d == null:
			continue
		d["time"] = FileAccess.get_modified_time(path+f)
		var flag = false
		for k in DEF_POOL:
			if k not in d:
				flag = true
		if flag:
			continue
		pools.append(d)
	pools.sort_custom(func (a, b): return a.time > b.time)
	for pool in pools:
		item_list.add_item(pool.name)


func _on_form_submitted():
	visible = false
	get_parent().visible = false
	var i = item_list.get_selected_items()[0]
	if i == 0:
		var d = form.get_values()
		var pool = Pool.new()
		for k in DEF_POOL:
			pool.set(k, d[k])
		Global.set_pool(pool)
	else:
		i = i-1
		var d = pools[i]
		Global.set_pool(Pool.from_dict(d))
	

func _on_item_list_item_selected(index):
	if index == 0:
		form.set_active(true)
		form.set_values(DEF_POOL)
	else:
		form.set_active(false)
		form.set_values(pools[index - 1])
