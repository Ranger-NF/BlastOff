extends Node

signal screen_size_updated(new_screen_size: Vector2)

signal game_started
signal game_over

signal rocket_speed_changed(new_speed: float)
signal level_up

signal time_phase_changed(current_time_phase: int)

enum TIME_PHASES {
    DAY,
    NIGHT
}

var game_screen_size: Vector2:
    set(value):
        if value != game_screen_size: # Value has changed
            game_screen_size = value
            self.emit_signal("screen_size_updated", value)

var rocket_speed: float = 600

## For controlling inputs
var is_left_button_pressed: bool = false
var is_right_button_pressed: bool = false
var screen_mid_x_pos: float # Changed from main.gd

var flock_probability: float = 0.2
var satellite_falling_propability: float = 0.1

func _ready() -> void:
    self.level_up.connect(_increase_difficulty)
    self.rocket_speed_changed.connect(_on_rocket_speed_changed)
    self.game_started.connect(_reset_values)

func _on_rocket_speed_changed(new_speed: float):
    rocket_speed = new_speed

func _increase_difficulty() -> void:
    flock_probability += 0.05
    satellite_falling_propability += 0.05

    emit_signal("rocket_speed_changed", rocket_speed + 100)

func _reset_values() -> void:
    is_left_button_pressed = false
    is_right_button_pressed = false

