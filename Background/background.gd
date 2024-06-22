extends Control

@onready var day_sky: TextureRect = $DaySky
@onready var night_sky: TextureRect = $NightSky

@onready var bg_star_node: TextureRect = $Star

const DAY_PROPABILITY: float = 0.5
const MOTHER_STAR_SPAWN_MARGIN: float = 25

var is_day_time: bool = true

var is_in_initial_setup: bool = true

func _ready() -> void:
    GameManager.time_phase_changed.connect(_on_time_phase_change)
    GameManager.screen_size_updated.connect(_on_screen_size_updated)

    _select_day_or_night()

func _select_day_or_night() -> void:
    var rand_num: float = randf()

    if rand_num > DAY_PROPABILITY:
        is_day_time = true
        GameManager.emit_signal("time_phase_changed", GameManager.TIME_PHASES.DAY)
    else:
        is_day_time = false
        GameManager.emit_signal("time_phase_changed", GameManager.TIME_PHASES.NIGHT)

func _on_time_phase_change(time_phase: int):
    if time_phase == GameManager.TIME_PHASES.DAY:
        day_sky.show()
        night_sky.hide()
    elif time_phase == GameManager.TIME_PHASES.NIGHT:
        night_sky.show()
        day_sky.hide()

        if is_in_initial_setup:
            await GameManager.screen_size_updated
            _spawn_stars()

func _on_screen_size_updated(screen_size: Vector2):
    if is_in_initial_setup:
        is_in_initial_setup = false

        $LightEmitter.position.x = screen_size.x * 0.8
        $LightEmitter.position.y = randf_range(0, screen_size.y * 0.3)

func _spawn_stars() -> void:
    var mother_star_location: Vector2 = Vector2(randf_range(0 + MOTHER_STAR_SPAWN_MARGIN, GameManager.game_screen_size.x - MOTHER_STAR_SPAWN_MARGIN) , randf_range(0 + MOTHER_STAR_SPAWN_MARGIN, GameManager.game_screen_size.y - MOTHER_STAR_SPAWN_MARGIN))
    bg_star_node.position = mother_star_location
