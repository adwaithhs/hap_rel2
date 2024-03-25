@tool
extends Control

@export
var key:= "name"
@export
var text:= "Name"
@export
var value:= "Text"

func _ready():
	$MarginContainer/Label.text = text
	$LineEdit.text = value

func update():
	value = $LineEdit.text

func set_value(val):
	value = val
	$LineEdit.text = value
