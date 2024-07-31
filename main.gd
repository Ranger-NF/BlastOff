extends Node

@onready var bg_music_list: Array = [
    preload("res://Music/bravery_demon.ogg"),
    preload("res://Music/bravery_run.ogg"),
    preload("res://Music/homely_arcade.ogg")
]

@onready var obstacle_spawn_node: Path2D = $ObstaclePath

@onready var bird_timer: Timer = $BirdTimer
@onready var satellite_timer: Timer = $SatelliteTimer
@onready var star_timer: Timer = $StarTimer

@onready var obstacle_path = $ObstaclePath/PathFollow2D
@onready var music_player = $Music

const OBSTACLE_SPAWN_MARGIN: float = 20

var is_game_running: bool = false

func _ready() -> void:
    GameManager.screen_size_updated.connect(_on_screen_size_updated)

    GameManager.game_started.connect(restart_game)
    GameManager.game_over.connect(_on_game_over)

    UiManager.main_scene = self
    UiManager.emit_signal("skipped_to_main_menu")

    _start_rand_music()

func _setup_spawn_line() -> void:
    obstacle_spawn_node.curve.clear_points()

    var horizontal_screen_size = GameManager.game_screen_size.x

    obstacle_spawn_node.curve.add_point(Vector2(0 + OBSTACLE_SPAWN_MARGIN, 0))
    obstacle_spawn_node.curve.add_point(Vector2(horizontal_screen_size - OBSTACLE_SPAWN_MARGIN, 0))

func spawn_obstacle(obstacle_type: int):
    var obstacle_node: Node2D = ObstacleManager.get_free_obstacle(obstacle_type)

    obstacle_path.progress_ratio = randf()

    var rand_xpos_on_path = obstacle_path.position.x
    var spawn_location = Vector2(rand_xpos_on_path, -250)

    obstacle_node.position = spawn_location

    add_child(obstacle_node)

func _on_game_over() -> void:
    is_game_running = false
    bird_timer.stop()
    satellite_timer.stop()
    star_timer.stop()

func restart_game() -> void:
    is_game_running = true
    bird_timer.start(0.5)
    star_timer.start(1)
    satellite_timer.start(0.75)

func _on_bird_timer_timeout() -> void:
    spawn_obstacle(ObstacleManager.BIRD)
    bird_timer.start(randf_range(ObstacleManager.current_bird_spawning_interval.x, ObstacleManager.current_bird_spawning_interval.y))

func _on_satellite_timer_timeout() -> void:
    var random_num = randf()
    if (random_num < ObstacleManager.current_satellite_spawning_propability):
        spawn_obstacle(ObstacleManager.SATELLITE)

    if satellite_timer.is_stopped():
        satellite_timer.start(randf_range(ObstacleManager.current_satellite_spawning_interval.x, ObstacleManager.current_satellite_spawning_interval.y))

func _on_star_timer_timeout() -> void:
    spawn_obstacle(ObstacleManager.STAR)

    if star_timer.is_stopped():
        star_timer.start(randf_range(ObstacleManager.current_star_spawning_interval.x, ObstacleManager.current_star_spawning_interval.y))

func _on_music_finished() -> void:
    _start_rand_music()

func _start_rand_music() -> void:
    music_player.stream = bg_music_list.pick_random()
    music_player.play()

func _on_screen_size_updated(_screen_size: Vector2) -> void:
    _setup_spawn_line()
