extends Control

@onready
var line_edit = $MarginContainer/HBoxContainer/LineEdit

func _ready():
	line_edit.text = str(Global.i)

func refresh():
	line_edit.text = str(Global.i)

func _on_line_edit_text_submitted(new_text):
	var pool = Global.pool
	if pool == null: return
	Global.set_i(int(new_text))
	line_edit.text = str(Global.i)
	Global.ch_changed.emit()


func _on_ll_button_down():
	Global.set_i(1)
	line_edit.text = str(Global.i)
	Global.ch_changed.emit()


func _on_l_button_down():
	Global.set_i(Global.i - 1)
	line_edit.text = str(Global.i)
	Global.ch_changed.emit()


func _on_r_button_down():
	Global.set_i(Global.i + 1)
	line_edit.text = str(Global.i)
	Global.ch_changed.emit()


func _on_rr_button_down():
	Global.set_i(1, true)
	line_edit.text = str(Global.i)
	Global.ch_changed.emit()
