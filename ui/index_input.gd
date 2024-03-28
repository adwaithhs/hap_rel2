extends Control

@onready
var line_edit = $MarginContainer/HBoxContainer/LineEdit

@export
var dir:= 1

var index
var get_idx: Callable

signal index_changed(k: int)
signal index_changed_by(k: int, inf: bool)

func _ready():
	refresh()

func refresh():
	if get_idx:
		set_index(get_idx.call())

func set_index(i):
	index = i
	line_edit.text = str(i)

func _on_line_edit_text_submitted(new_text):
	index_changed.emit(int(new_text))
	refresh()

func _on_ll_button_down():
	index_changed_by.emit(-dir, true)
	refresh()


func _on_l_button_down():
	index_changed_by.emit(-dir, false)
	refresh()


func _on_r_button_down():
	index_changed_by.emit(+dir, false)
	refresh()


func _on_rr_button_down():
	index_changed_by.emit(+dir, true)
	refresh()
