extends Node

signal game_started
signal game_over

signal player_health_changed
signal rocket_speed_changed

var rocket_speed: float = 600

var is_left_button_pressed: bool = false
var is_right_button_pressed: bool = false


func _ready() -> void:
    self.rocket_speed_changed.connect(_increase_speed)

func _increase_speed() -> void:
    rocket_speed += 100
