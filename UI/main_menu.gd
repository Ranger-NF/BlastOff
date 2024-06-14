extends Control

@onready var button_pressed_sound: AudioStreamPlayer = $ButtonSound
@onready var high_score_label: Label = $VBoxContainer/TitleBox/VBoxContainer/HighScore
@onready var title_texture: TextureRect = $VBoxContainer/TitleBox/VBoxContainer/Title

func _ready() -> void:
    self.child_entered_tree.connect(_update_high_score)
    _update_high_score()
    _pulsate()

func _update_high_score(_node: Node = null) -> void:
    if DataManager.gameplay.high_score > 0:
        high_score_label.text = "High Score: " + str(DataManager.gameplay.high_score)
        high_score_label.show()

func _on_play_button_pressed() -> void:
    _on_button_pressed()
    UiManager.emit_signal("triggered_gamearea_setup")

func _on_quit_button_pressed() -> void:
    _on_button_pressed()
    get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
    get_tree().quit()

func _on_options_button_pressed() -> void:
    _on_button_pressed()
    UiManager.emit_signal("opened_settings")

func _on_button_pressed() -> void:
    button_pressed_sound.play()

func _pulsate() -> void:
    var PULSATE_PERIOD: float = 0.5
    var initial_title_y = title_texture.position.y
    while 1 > 0:
        var tween = create_tween().set_parallel(true)
        tween.tween_property(title_texture, "position", Vector2(title_texture.position.x, initial_title_y + 3), PULSATE_PERIOD).set_trans(Tween.TRANS_CUBIC).set_delay(PULSATE_PERIOD * 0.74)
        tween.tween_property(title_texture, "position", Vector2(title_texture.position.x, initial_title_y), PULSATE_PERIOD).set_trans(Tween.TRANS_CUBIC).set_delay(PULSATE_PERIOD * 0.74 + PULSATE_PERIOD)
        await tween.finished


