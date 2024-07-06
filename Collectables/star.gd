extends Area2D

signal setup_node

@onready var back_shine_node = $BackShine
@onready var star_sptite: Sprite2D = $Star

@onready var collision_shape = $CollisionShape2D
@onready var star_collected_sound: AudioStreamPlayer = $StarCollectedSound

const SHINE_TIME_PERIOD: float = 3

var initial_shine_scale: Vector2
var can_glow: bool

func _ready() -> void:
    GameManager.game_over.connect(_on_game_over)
    self.setup_node.connect(_setup_star)


func _setup_star() -> void:
    can_glow = true
    _glow()

func _glow():
    initial_shine_scale = back_shine_node.scale
    while can_glow:
        var tween = create_tween().set_parallel(true)
        tween.tween_property(back_shine_node, "scale", initial_shine_scale * 2, SHINE_TIME_PERIOD / 2)
        tween.tween_property(back_shine_node, "scale", initial_shine_scale, SHINE_TIME_PERIOD / 2).set_delay(SHINE_TIME_PERIOD / 2)
        await tween.finished

func free_fall(delta) -> void:
    var moveable_y: float = (GameManager.rocket_speed * delta)

    self.position.y += moveable_y

func _physics_process(delta: float) -> void:
    free_fall(delta)

func make_disappear() -> void:
    var tween = create_tween().set_parallel(true)
    tween.tween_property(back_shine_node, "scale", initial_shine_scale * 2, SHINE_TIME_PERIOD / 2)
    tween.tween_property(back_shine_node, "modulate:a", 0, SHINE_TIME_PERIOD / 2)
    await tween.finished

    free_obstacle()

func _on_hit() -> void:
    collision_shape.set_deferred("disabled", true)
    StatManager.emit_signal("star_count_changed", 1)

    star_collected_sound.pitch_scale = randf_range(1, 1.5)
    star_collected_sound.play()

    $CPUParticles2D.emitting = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    free_obstacle()

func _on_game_over() -> void:
    free_obstacle()

func _on_star_collected_sound_finished() -> void:
    free_obstacle()

func free_obstacle() -> void:
    can_glow = false
    ObstacleManager.make_obstacle_free(self, ObstacleManager.STAR)
