extends Node

@export var star_scene: PackedScene

@onready var bg_music_list: Array = [
    preload("res://Music/bravery_demon.ogg"),
    preload("res://Music/bravery_run.ogg"),
    preload("res://Music/homely_arcade.ogg")
]

@onready var obstacle_spawn_node: Path2D = $ObstaclePath

@onready var obstacle_timer: Timer = $ObstacleTimer
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

func _physics_process(delta: float) -> void:
    if is_game_running:
        StatManager.time_spent += delta

func spawn_obstacle(obstacle_node: Node):
    if not obstacle_node:
        push_error("No such obstacle found in the path!")

    obstacle_path.progress_ratio = randf()

    var rand_xpos_on_path = obstacle_path.position.x
    var spawn_location = Vector2(rand_xpos_on_path, -250)

    obstacle_node.position = spawn_location

    add_child(obstacle_node)


func determine_next_obstacle():

    var random_num = randf()
    if (random_num < ObstacleManager.satellite_falling_propability):
        if satellite_timer.is_stopped():
            satellite_timer.start(randi_range(2, 6))
    else:
        if star_timer.is_stopped():
            star_timer.start(randi_range(1, 5))

    spawn_obstacle(ObstacleManager.OBSTACLE_SCENES.get(ObstacleManager.BIRD))

func _on_game_over() -> void:
    is_game_running = false
    obstacle_timer.stop()
    satellite_timer.stop()
    star_timer.stop()

func restart_game() -> void:
    is_game_running = true
    StatManager.time_spent = 0
    obstacle_timer.start()

func _on_asteroid_timer_timeout() -> void:
    obstacle_timer.wait_time = randf_range(0.5, 2.5)
    determine_next_obstacle()

func _on_satellite_timer_timeout() -> void:
    spawn_obstacle(ObstacleManager.OBSTACLE_SCENES.get(ObstacleManager.SATELLITE))

func _on_star_timer_timeout() -> void:
    spawn_obstacle(star_scene.instantiate())

func _on_music_finished() -> void:
    _start_rand_music()

func _start_rand_music() -> void:
    music_player.stream = bg_music_list.pick_random()
    music_player.play()

func _on_screen_size_updated(_screen_size: Vector2) -> void:
    _setup_spawn_line()
