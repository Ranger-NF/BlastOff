extends Area2D

@onready var back_shine_node = $BackShine
@onready var collision_shape = $CollisionShape2D

const SHINE_TIME_PERIOD: float = 3

var initial_shine_scale: Vector2

func _ready() -> void:
    _spin_shine()

func _spin_shine():
    initial_shine_scale = back_shine_node.scale
    while 1 > 0:
        var tween = create_tween().set_parallel(true)
        tween.tween_property(back_shine_node, "scale", initial_shine_scale * 2, SHINE_TIME_PERIOD / 2)
        tween.tween_property(back_shine_node, "scale", initial_shine_scale, SHINE_TIME_PERIOD / 2).set_delay(SHINE_TIME_PERIOD / 2)
        await tween.finished

func free_fall(delta) -> void:
    var moveable_y: float = (GameManager.rocket_speed * delta)

    self.position.y += moveable_y

func _physics_process(delta: float) -> void:
    free_fall(delta)

func _on_hit() -> void:
    collision_shape.set_deferred("disabled", true)
    #hit_sound.play()
    if self.has_method("_after_hit"): self.call("_after_hit")

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    queue_free()
