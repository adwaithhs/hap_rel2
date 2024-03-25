@tool

extends Control

@export
var text:= "Title"

func _ready():
	$PanelContainer/Label.text = text

