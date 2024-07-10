extends ParallaxBackground

@onready var night_cloud_changer: CanvasModulate = $NightCanvasModulate
@onready var ui_canvas_modulate: CanvasModulate = $UICanvasModulate

@onready var distant_clouds_node: ParallaxLayer = $DistantClouds

var is_game_running: bool = false

const IDLE_WIND_SPEED: float = 10

func _ready() -> void:
    _change_background_mode(true)

    GameManager.screen_size_updated.connect(_on_screen_size_updated)
    GameManager.game_started.connect(_on_game_start)
    GameManager.game_over.connect(_on_game_over)

    UiManager.time_phase_changed.connect(_on_time_phase_change)

func _on_time_phase_change(time_phase: int):
    if time_phase == UiManager.TIME_PHASES.DAY:
        night_cloud_changer.hide()
    elif time_phase == UiManager.TIME_PHASES.NIGHT:
        night_cloud_changer.show()

func _on_screen_size_updated(screen_size: Vector2):
    self.offset.x = screen_size.x / 2

func _on_game_start() -> void:
    is_game_running = true
    _change_background_mode(false)

func _on_game_over() -> void:
    is_game_running = false
    _change_background_mode(true)

func _physics_process(delta: float) -> void:
    if is_game_running:
        self.scroll_offset.y += GameManager.rocket_speed * delta

    self.scroll_offset.x += IDLE_WIND_SPEED * delta

func _change_background_mode(is_in_menu: bool):
    if is_in_menu:
        distant_clouds_node.hide()
        ui_canvas_modulate.show()
    else:
        distant_clouds_node.show()
        ui_canvas_modulate.hide()
