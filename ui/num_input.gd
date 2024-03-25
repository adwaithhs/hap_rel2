@tool
extends Control

@export
var key:= "n"
@export
var text:= "n"
@export
var value:= 100.0

func _ready():
	$MarginContainer/Label.text = text
	$LineEdit.text = str(value)

func update():
	value = float($LineEdit.text)
	$LineEdit.text = str(value)

func set_value(val):
	value = val
	$LineEdit.text = str(value)
