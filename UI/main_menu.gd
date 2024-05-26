extends CanvasLayer

func _ready() -> void:
    UiManager.skipped_to_main_menu.connect(_show_ui)

func _show_ui() -> void:
    self.show()

func _on_play_button_pressed() -> void:
    self.hide()
    GameManager.emit_signal("game_started")


func _on_quit_button_pressed() -> void:
    get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
    get_tree().quit()
