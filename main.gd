extends Node

@export var bird_scene: PackedScene
@export var satellite_scene: PackedScene

@onready var obstacle_timer: Timer = $ObstacleTimer
@onready var satellite_timer: Timer = $SatelliteTimer

@onready var obstacle_path = $ObstaclePath/PathFollow2D
@onready var music_player = $Music

var is_game_running: bool = false

func _ready() -> void:
    GameManager.game_started.connect(restart_game)
    GameManager.game_over.connect(_on_game_over)

    UiManager.emit_signal("skipped_to_main_menu")


func _physics_process(delta: float) -> void:
    if is_game_running:
        StatManager.time_spent += delta

func spawn_obstacle(obstacle_scene: PackedScene):
    if not obstacle_scene:
        push_error("PackedScene is not set in the export section!")

    obstacle_path.progress_ratio = randf()

    var rand_xpos_on_path = obstacle_path.position.x
    var spawn_location = Vector2(rand_xpos_on_path, -250)

    var new_obstacle = obstacle_scene.instantiate()
    new_obstacle.position = spawn_location

    add_child(new_obstacle)


func determine_next_obstacle():

    var random_num = randf()
    if (random_num < GameManager.satellite_falling_propability):
        if satellite_timer.is_stopped():
            satellite_timer.start(randi_range(4, 6))

    spawn_obstacle(bird_scene)

func _on_game_over() -> void:
    is_game_running = false
    obstacle_timer.stop()
    satellite_timer.stop()

func restart_game() -> void:
    is_game_running = true
    StatManager.time_spent = 0
    obstacle_timer.start()

func _on_asteroid_timer_timeout() -> void:
    obstacle_timer.wait_time = randf_range(1, 3)
    determine_next_obstacle()

func _on_satellite_timer_timeout() -> void:
    spawn_obstacle(satellite_scene)
