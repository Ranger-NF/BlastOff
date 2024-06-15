extends Control

@onready var button_pressed_sound = $ButtonSound
@onready var score_label = $NavBoxMargin/NavBox/Score

func _ready() -> void:
    self.child_entered_tree.connect(_update_score)
    _update_score()

func _update_score(_node: Node= null) -> void:
    score_label.text = "Score: " + str(StatManager.score_gained)

func _on_restart_button_pressed() -> void:
    _on_button_pressed()
    UiManager.emit_signal("triggered_gamearea_setup")

func _on_back_button_pressed() -> void:
    _on_button_pressed()
    UiManager.emit_signal("skipped_to_main_menu")

func _on_button_pressed() -> void:
    button_pressed_sound.play()
