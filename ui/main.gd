extends Control

@onready
var form = $PanelContainer2/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Form
@onready
var form2 = $PanelContainer2/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Form2
@onready
var form3 = $PanelContainer2/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Form3
@onready
var figure = $Figure
@onready
var index_input = $MarginContainer/VBoxContainer/CenterContainer/IndexInput
@onready
var index_input2 = $MarginContainer/VBoxContainer/CenterContainer2/IndexInput
@onready
var left_dock = $PanelContainer2
@onready
var right_dock = $PanelContainer
@onready
var label = $PanelContainer/MarginContainer/Label

func _ready():
	Global.main_scene = self
	Global.ch_changed.connect(on_ch_changed)
	index_input.index_changed.connect(Global.set_i)
	index_input2.index_changed.connect(Global.set_j)
	index_input.index_changed_by.connect(Global.change_i)
	index_input2.index_changed_by.connect(Global.change_j)
	index_input.get_idx = func (): return Global.i
	index_input2.get_idx = func (): return Global.j

func on_ch_changed():
	figure.queue_redraw()
	index_input.refresh()
	index_input2.refresh()
	label.text = ""
	var ch = Global.get_ch()
	if ch == null: return
	label.text = (
		"r: " + str(ch.score_r) + "\n" +
		"g: " + str(ch.cost_g) + "\n" +
		"distn:\n" + JSON.stringify(ch.distn, " ") + "\n"
	)

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_H: # TODO
			var v = not left_dock.visible
			index_input.visible = v
			index_input2.visible = v
			left_dock.visible = v
			right_dock.visible = v
		if event.keycode == KEY_S:
			if Global.pool:
				Global.pool.save()
		if event.keycode == KEY_P:
			var ch = Global.get_ch()
			if ch == null: return
			print()


func _on_form_2_submitted():
	var d = form2.get_values()
	d["key"] = "random"
	Global.do_action(d)

func _on_form_3_submitted():
	var d = form3.get_values()
	d["key"] = "step"
	Global.do_action(d)
