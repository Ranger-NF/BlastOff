extends Control

signal back_button_pressed

@onready var high_score_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/HighScore

func _ready() -> void:
    self.back_button_pressed.connect(_on_back_button_pressed)
    self.child_entered_tree.connect(_update_high_score)

func _update_high_score(_node: Node = null) -> void:
    high_score_label.text = str(DataManager.gameplay.high_score)
    high_score_label.show()

func _on_back_button_pressed() -> void:
    UiManager.emit_signal("skipped_to_main_menu")
