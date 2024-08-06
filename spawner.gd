extends Path2D

@onready var obstacle_path = $PathFollow2D2

@onready var bird_timer: Timer = $BirdTimer
@onready var satellite_timer: Timer = $SatelliteTimer
@onready var star_timer: Timer = $StarTimer
@onready var powerup_timer: Timer = $PowerupTImer

# Timer range
const POWERUP_COOLDOWN: Vector2 = Vector2(10,17) # (min, max)

const OBSTACLE_SPAWN_MARGIN: float = 20

func _ready() -> void:
    GameManager.screen_size_updated.connect(_on_screen_size_updated)

    GameManager.start_spawning.connect(_on_start_spawning)
    GameManager.stop_spawning.connect(_on_stop_spawning)

    bird_timer.timeout.connect(_on_bird_timer_timeout)
    star_timer.timeout.connect(_on_star_timer_timeout)
    satellite_timer.timeout.connect(_on_satellite_timer_timeout)
    powerup_timer.timeout.connect(_on_powerup_timer_timeout)

    _setup_spawn_line()

func _on_screen_size_updated(_screen_size: Vector2) -> void:
    _setup_spawn_line()

func _setup_spawn_line() -> void:
    self.curve.clear_points()

    var horizontal_screen_size = GameManager.game_screen_size.x

    self.curve.add_point(Vector2(0 + OBSTACLE_SPAWN_MARGIN, 0))
    self.curve.add_point(Vector2(horizontal_screen_size - OBSTACLE_SPAWN_MARGIN, 0))

func spawn_obstacle(obstacle_type: int):
    var obstacle_node: Node2D = SpawnManager.get_free_obstacle(obstacle_type)

    obstacle_path.progress_ratio = randf()

    var rand_xpos_on_path = obstacle_path.position.x
    var spawn_location = Vector2(rand_xpos_on_path, -250)

    obstacle_node.position = spawn_location

    add_child(obstacle_node)

func _on_stop_spawning() -> void:
    bird_timer.stop()
    satellite_timer.stop()
    star_timer.stop()
    powerup_timer.stop()

func _on_start_spawning() -> void:
    bird_timer.start(0.5)
    star_timer.start(1)
    satellite_timer.start(0.75)
    powerup_timer.start(2)

func _on_bird_timer_timeout() -> void:
    spawn_obstacle(SpawnManager.BIRD)
    bird_timer.start(randf_range(SpawnManager.current_bird_spawning_interval.x, SpawnManager.current_bird_spawning_interval.y))

func _on_satellite_timer_timeout() -> void:
    var random_num = randf()
    if (random_num < SpawnManager.current_satellite_spawning_propability):
        spawn_obstacle(SpawnManager.SATELLITE)

    if satellite_timer.is_stopped():
        satellite_timer.start(randf_range(SpawnManager.current_satellite_spawning_interval.x, SpawnManager.current_satellite_spawning_interval.y))

func _on_star_timer_timeout() -> void:
    spawn_obstacle(SpawnManager.STAR)

    if star_timer.is_stopped():
        star_timer.start(randf_range(SpawnManager.current_star_spawning_interval.x, SpawnManager.current_star_spawning_interval.y))

func _on_powerup_timer_timeout() -> void:
    var rand_float: float = randf()

    if rand_float > 0.5:
        spawn_obstacle(SpawnManager.SHIELD)
    else:
        spawn_obstacle(SpawnManager.BOOST)

    if powerup_timer.is_stopped():
        powerup_timer.start(randf_range(POWERUP_COOLDOWN.x, POWERUP_COOLDOWN.y))
