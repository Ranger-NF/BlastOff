extends Node

signal game_started
signal game_over

signal player_health_changed
signal level_up

var rocket_speed: float = 600

var is_left_button_pressed: bool = false
var is_right_button_pressed: bool = false

var flock_probability: float = 0.2
var satellite_falling_propability: float = 0.2

func _ready() -> void:
    self.level_up.connect(_increase_difficulty)

func _increase_difficulty() -> void:
    rocket_speed += 100
    flock_probability += 0.05
    satellite_falling_propability += 0.05

