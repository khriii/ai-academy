extends Control

@export var start_message_label: Label

var start_message: String = "Premi un tasto per iniziare..."

func _ready() -> void:
	start_message_label.text = start_message
