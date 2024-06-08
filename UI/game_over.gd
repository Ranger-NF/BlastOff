extends Control

@onready var button_pressed_sound = $ButtonSound
@onready var score_label = $NavBoxMargin/NavBox/Score

func _ready() -> void:
    score_label.text = "Score: " + str(DataManager.gameplay.high_score)

func _on_restart_button_pressed() -> void:
    _on_button_pressed()
    GameManager.emit_signal("game_started")

func _on_back_button_pressed() -> void:
    _on_button_pressed()
    UiManager.emit_signal("skipped_to_main_menu")

func _on_button_pressed() -> void:
    button_pressed_sound.play()