extends Control

@onready var button_pressed_sound: AudioStreamPlayer = $ButtonSound

func _ready() -> void:
    UiManager.skipped_to_main_menu.connect(_show_ui)

func _show_ui() -> void:
    self.show()

func _on_play_button_pressed() -> void:
    _on_button_pressed()
    self.hide()
    GameManager.emit_signal("game_started")


func _on_quit_button_pressed() -> void:
    _on_button_pressed()
    get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
    get_tree().quit()

func _on_options_button_pressed() -> void:
    _on_button_pressed()
    self.hide()
    UiManager.emit_signal("opened_settings")

func _on_button_pressed() -> void:
    button_pressed_sound.play()


