extends "res://Enemies/Obstacle.gd"

@onready var parts_group: Node2D = $Parts
@onready var smoke_partcile_node: CPUParticles2D = $Parts/SmokeParticles

var instance_id: int
var initial_smoke_speed: float

var spin_tween: Tween

func _further_setup() -> void:
    smoke_partcile_node.emitting = false
    instance_id = StatManager.satellite_number # Gives it unique id
    StatManager.satellite_number += 1

    GameManager.game_over.connect(func (): UiManager.emit_signal("warning_withdrawn", instance_id))
    can_move = false
    UiManager.emit_signal("warning_announced", self.position.x, instance_id)
    $WarnTimer.start(1)

    _select_random_parts()

    initial_smoke_speed = GameManager.rocket_speed
    update_smoke_speed(initial_smoke_speed)
    GameManager.rocket_speed_changed.connect(update_smoke_speed)

func _select_random_parts() -> void:
    var spawnable_parts: Array[Node] = $Parts.get_children()
    spawnable_parts.erase(smoke_partcile_node)
    var num_of_parts: int = randi_range(1 , 3)

    var num_of_selected_parts: int = 0
    var list_of_selected_parts: Array[Node] = []


    if num_of_parts > 1: # Includes the main body as one of the parts (To make satellite more believable)
        num_of_selected_parts += 1
        var body_part = spawnable_parts.filter(func(part_node): return part_node.name == "MainBody").front()
        spawnable_parts.erase(body_part)
        list_of_selected_parts.append(body_part)

    # Randomly choosing parts of satellite
    while num_of_selected_parts < num_of_parts:
        num_of_selected_parts += 1

        var selected_part: Node = spawnable_parts[randi_range(0, len(spawnable_parts) - 1)]
        spawnable_parts.erase(selected_part)

        list_of_selected_parts.append(selected_part)

    spawn_parts(list_of_selected_parts)

func spawn_parts(parts: Array[Node]) -> void:
    var has_main_body: bool = false

    for each_part in parts:
        each_part.find_child("CollisionShape2D").reparent(self)
        each_part.show()

        if each_part.name == "MainBody":
            has_main_body = true

    if not has_main_body:
        smoke_partcile_node.position = parts.pick_random().position

func _on_warn_timer_timeout() -> void:
    can_move = true
    smoke_partcile_node.emitting = true
    UiManager.emit_signal("warning_withdrawn", instance_id)

func update_smoke_speed(new_rocket_speed: float):
    var calculated_smoke_speed = absf((new_rocket_speed - (new_rocket_speed * free_fall_multiplier)))
    smoke_partcile_node.initial_velocity_min = calculated_smoke_speed * 0.5
    smoke_partcile_node.initial_velocity_max = calculated_smoke_speed

func _after_hit() -> void:
    UiManager.emit_signal("triggered_screen_shake", UiManager.STRENGTH_TYPES.HIGH)
    smoke_partcile_node.amount = roundi(smoke_partcile_node.amount * 1.5)
    smoke_partcile_node.lifetime = smoke_partcile_node.lifetime * 1.5

    _spin_slightly()

func _spin_slightly() -> void:
    if spin_tween and spin_tween.is_running():
        spin_tween.stop()
        spin_tween.kill()

    spin_tween = create_tween()

    while not self.is_queued_for_deletion():
        spin_tween.tween_property(self, "rotation", deg_to_rad(360), 5).set_ease(Tween.EASE_IN)
        if not self.is_inside_tree():
            spin_tween.kill()
            break
        await spin_tween.finished

