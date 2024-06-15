extends ParallaxBackground

@onready var night_cloud_changer: CanvasModulate = $NightCanvasModulate
@onready var day_sky: TextureRect = $Node2D/DaySky
@onready var night_sky: TextureRect = $Node2D/NightSky

var is_game_running: bool = false
const IDLE_WIND_SPEED: float = 10

var is_day_time: bool = false

func _ready() -> void:
    GameManager.game_started.connect(_on_game_start)
    GameManager.game_over.connect(_on_game_over)

    if not is_day_time:
        night_sky.show()
        night_cloud_changer.show()

        day_sky.hide()
    else:
        day_sky.show()

        night_sky.hide()
        night_cloud_changer.hide()

func _on_game_start() -> void:
    is_game_running = true

func _on_game_over() -> void:
    is_game_running = false

func _physics_process(delta: float) -> void:
    if is_game_running:
        scroll_offset.y += GameManager.rocket_speed * delta
    if not is_game_running:
        scroll_offset.x += IDLE_WIND_SPEED * delta
