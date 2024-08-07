extends Control

signal back_button_pressed

func _ready() -> void:
    self.back_button_pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
    UiManager.emit_signal("opened_start_menu")
