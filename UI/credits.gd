extends Control

@onready var button_pressed_sound = $ButtonSound

func _ready() -> void:
    self.hide()
    UiManager.opened_credits.connect(_show_credits)

func _show_credits() -> void:
    self.show()

func _on_back_button_pressed() -> void:
    self.hide()
    _on_button_pressed()
    UiManager.emit_signal("skipped_to_main_menu")

func _on_button_pressed() -> void:
    button_pressed_sound.play()
