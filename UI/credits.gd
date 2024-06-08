extends Control

@onready var button_pressed_sound = $ButtonSound

func _on_back_button_pressed() -> void:
    _on_button_pressed()
    UiManager.emit_signal("skipped_to_main_menu")

func _on_button_pressed() -> void:
    button_pressed_sound.play()

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
    OS.shell_open(meta)
