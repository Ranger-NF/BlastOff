extends Control

@onready var button_pressed_sound: AudioStreamPlayer = $ButtonSound
@onready var high_score_label: Label = $VBoxContainer/TitleBox/VBoxContainer/HighScore

func _ready() -> void:
    self.child_entered_tree.connect(_update_high_score)
    _update_high_score()

func _update_high_score(_node: Node = null) -> void:
    if DataManager.gameplay.high_score > 0:
        high_score_label.text = "High Score: " + str(DataManager.gameplay.high_score)
        high_score_label.show()

func _on_play_button_pressed() -> void:
    _on_button_pressed()
    GameManager.emit_signal("game_started")

func _on_quit_button_pressed() -> void:
    _on_button_pressed()
    get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
    get_tree().quit()

func _on_options_button_pressed() -> void:
    _on_button_pressed()
    UiManager.emit_signal("opened_settings")

func _on_button_pressed() -> void:
    button_pressed_sound.play()


