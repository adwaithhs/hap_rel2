extends Control

class_name MyButton

signal pressed

func _on_button_button_down():
	pressed.emit()
