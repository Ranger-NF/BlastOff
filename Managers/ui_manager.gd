extends Node

signal warning_announced(x_position: float, warning_id: int) # For showing a warning sign when heavy objects are falling
signal warning_withdrawn(warning_id: int)

signal skipped_to_main_menu
signal opened_settings
signal opened_credits

signal first_startup
signal show_tutorial

var need_tutorial: bool = false

func _ready() -> void:
    self.first_startup.connect(func () -> void: need_tutorial = true)
    GameManager.game_started.connect(_check_tutorial_need)

func _check_tutorial_need() -> void:
    if need_tutorial:
        emit_signal("show_tutorial")
        need_tutorial = false
