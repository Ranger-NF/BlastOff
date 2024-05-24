extends ParallaxBackground

var is_game_running: bool = false

func _on_game_start() -> void:
    is_game_running = true

func _on_game_over() -> void:
    is_game_running = false

func _physics_process(delta: float) -> void:
    if is_game_running:
        $Clouds.scroll_base_offset.y += GameManager.rocket_speed * delta
