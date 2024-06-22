extends Control

@onready var night_cloud_changer: CanvasModulate = $Background/NightCanvasModulate
@onready var day_sky: TextureRect = $DaySky
@onready var night_sky: TextureRect = $NightSky
@onready var parallax_parent: ParallaxBackground = $Background

var is_game_running: bool = false
const IDLE_WIND_SPEED: float = 10

var is_day_time: bool = true

func _ready() -> void:
    GameManager.screen_size_updated.connect(_on_screen_size_updated)
    GameManager.game_started.connect(_on_game_start)
    GameManager.game_over.connect(_on_game_over)

    _select_day_or_night()

    if not is_day_time:
        night_sky.show()
        night_cloud_changer.show()

        day_sky.hide()
    else:
        day_sky.show()

        night_sky.hide()
        night_cloud_changer.hide()

func _select_day_or_night() -> void:
    var rand_num: float = randf()

    if rand_num < 0.5:
        is_day_time = false

func _on_screen_size_updated(screen_size: Vector2):
    parallax_parent.offset.x = screen_size.x / 2
    $LightEmitter.position.x = screen_size.x * 0.8
    $LightEmitter.position.y = randf_range(0, screen_size.y * 0.3)

func _on_game_start() -> void:
    is_game_running = true

func _on_game_over() -> void:
    is_game_running = false

func _physics_process(delta: float) -> void:
    if is_game_running:
        parallax_parent.scroll_offset.y += GameManager.rocket_speed * delta
    if not is_game_running:
        parallax_parent.scroll_offset.x += IDLE_WIND_SPEED * delta

func _spawn_star() -> void:
    pass
