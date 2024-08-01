extends Path2D

@onready var obstacle_path = $PathFollow2D

@onready var bird_timer: Timer = $BirdTimer
@onready var satellite_timer: Timer = $SatelliteTimer
@onready var star_timer: Timer = $StarTimer

const OBSTACLE_SPAWN_MARGIN: float = 20

func _ready() -> void:
    GameManager.screen_size_updated.connect(_on_screen_size_updated)

    GameManager.game_started.connect(restart_game)
    GameManager.game_over.connect(_on_game_over)

    bird_timer.timeout.connect(_on_bird_timer_timeout)
    star_timer.timeout.connect(_on_star_timer_timeout)
    satellite_timer.timeout.connect(_on_satellite_timer_timeout)

func _on_screen_size_updated(_screen_size: Vector2) -> void:
    _setup_spawn_line()

func _setup_spawn_line() -> void:
    self.curve.clear_points()

    var horizontal_screen_size = GameManager.game_screen_size.x

    self.curve.add_point(Vector2(0 + OBSTACLE_SPAWN_MARGIN, 0))
    self.curve.add_point(Vector2(horizontal_screen_size - OBSTACLE_SPAWN_MARGIN, 0))

func spawn_obstacle(obstacle_type: int):
    var obstacle_node: Node2D = ObstacleManager.get_free_obstacle(obstacle_type)

    obstacle_path.progress_ratio = randf()

    var rand_xpos_on_path = obstacle_path.position.x
    var spawn_location = Vector2(rand_xpos_on_path, -250)

    obstacle_node.position = spawn_location

    add_child(obstacle_node)

func _on_game_over() -> void:
    bird_timer.stop()
    satellite_timer.stop()
    star_timer.stop()

func restart_game() -> void:
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
