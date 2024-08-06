extends Node

signal screen_size_updated(new_screen_size: Vector2)

signal game_started
signal game_over

signal rocket_speed_changed(new_speed: float)
signal difficulty_level_changed(new_difficulty_level: int)

signal ordered_rocket_to_target(new_target_x_pos: float, side_expected: int)
signal rocket_has_reached_target

signal level_up

# To control spawning
signal stop_spawning # Called from UiManager
signal start_spawning

enum DIFFICULTY_LEVELS {
    EASY,
    NORMAL,
    HARD
}

var game_screen_size: Vector2:
    set(value):
        if value != game_screen_size: # Value has changed
            game_screen_size = value
            self.emit_signal("screen_size_updated", value)

var current_difficulty_level: int =  DIFFICULTY_LEVELS.EASY:
    set(new_difficulty_level):
        current_difficulty_level = new_difficulty_level
        self.emit_signal("difficulty_level_changed", current_difficulty_level)

var rocket_speed: float = 600
var current_rocket_x_pos: float

## For controlling inputs
var is_left_button_pressed: bool = false
var is_right_button_pressed: bool = false
var screen_mid_x_pos: float # Changed from main.gd

func _ready() -> void:
    self.level_up.connect(_increase_difficulty)
    self.rocket_speed_changed.connect(_on_rocket_speed_changed)
    self.game_started.connect(_reset_values)
    self.game_over.connect(_on_game_over)

    DataManager.data_reloaded.connect(_reload_data)

func _on_rocket_speed_changed(new_speed: float):
    rocket_speed = new_speed

func _increase_difficulty() -> void:
    emit_signal("rocket_speed_changed", rocket_speed + 100)

func _reset_values() -> void:
    is_left_button_pressed = false
    is_right_button_pressed = false

func _reload_data() -> void:
    current_difficulty_level = DataManager.gameplay.current_difficulty

func _on_game_over() -> void:
    self.emit_signal("stop_spawning")
