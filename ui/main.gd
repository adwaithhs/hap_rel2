extends Control

class_name MainScene

@onready
var form = $PanelContainer2/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Form
@onready
var form2 = $PanelContainer2/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Form2
@onready
var form3 = $PanelContainer2/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Form3
@onready
var figure = $Figure
@onready
var index_input = $MarginContainer/CenterContainer/IndexInput
@onready
var left_dock = $PanelContainer2
@onready
var right_dock = $PanelContainer
@onready
var label = $PanelContainer/MarginContainer/Label
@onready
var left_loading = $PanelContainer2/CenterContainer

func _ready():
	Global.main_scene = self
	Global.ch_changed.connect(on_ch_changed)
	Global.init()

func on_ch_changed():
	figure.queue_redraw()
	label.text = ""
	var ch = Global.get_ch()
	if ch == null: return
	label.text = (
		"score: " + str(ch.score) + "\n" +
		"r: " + str(ch.score_r) + "\n" +
		"g: " + str(ch.cost_g) + "\n" +
		"distn:\n" + JSON.stringify(ch.distn, " ") + "\n"
	)

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_H:
			var v = not left_dock.visible
			index_input.visible = v
			left_dock.visible = v
			right_dock.visible = v
		if event.keycode == KEY_S:
			Global.mutex.lock()
			if Global.in_action and Global.pool:
				Global.pool.save()
			Global.mutex.unlock()
		if event.keycode == KEY_P:
			var ch = Global.get_ch()
			if ch == null: return
			print()


func _on_form_2_submitted():
	var d = form2.get_values()
	d["key"] = "random"
	Global.post(d)

func _on_form_3_submitted():
	var d = form3.get_values()
	d["key"] = "step"
	Global.post(d)
