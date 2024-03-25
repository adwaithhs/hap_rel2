@tool
extends VBoxContainer

class_name Form

@export
var active:= true

signal submitted

func _ready():
	set_active(active)
	if Engine.is_editor_hint(): return
	for child in get_children():
		if child is MyButton:
			child.pressed.connect(on_button_pressed)

func on_button_pressed():
	submitted.emit()

func set_active(active: bool):
	self.active = active
	for child in get_children():
		if "value" in child:
			child.get_node("LineEdit").editable = active

func get_values():
	var ret = {}
	for child in get_children():
		if "value" in child:
			child.update()
			ret[child.key] = child.value
	return ret

func set_values(d):
	for child in get_children():
		if "value" in child and child.key in d:
			child.set_value(d[child.key])
