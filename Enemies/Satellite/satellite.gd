extends "res://Enemies/Obstacle.gd"

@onready var parts_group: Node2D = $Parts
var instance_id: int


func _further_setup() -> void:
    instance_id = StatManager.satellite_number # Gives it unique id
    StatManager.satellite_number += 1

    GameManager.game_over.connect(func (): UiManager.emit_signal("warning_withdrawn", instance_id))
    can_move = false
    UiManager.emit_signal("warning_announced", self.position.x, instance_id)
    $WarnTimer.start(2)

    _select_random_parts()

func _select_random_parts():
    var spawnable_parts: Array[Node] = $Parts.get_children()
    var num_of_parts: int = randi_range(1 , 3)

    var num_of_selected_parts: int = 0


    if num_of_parts > 1: # Includes the main body as one of the parts (To make satellite more believable)
        num_of_selected_parts += 1
        var body_part = spawnable_parts.filter(func(part_node): return part_node.name == "MainBody").front()
        spawnable_parts.erase(body_part)
        body_part.find_child("CollisionShape2D").reparent(self)
        body_part.show()

    # Randomly choosing parts of satellite
    while num_of_selected_parts < num_of_parts:
        print(spawnable_parts, num_of_selected_parts, num_of_parts)
        num_of_selected_parts += 1

        var selected_part: Node = spawnable_parts[randi_range(0, len(spawnable_parts) - 1)]
        spawnable_parts.erase(selected_part)
        selected_part.find_child("CollisionShape2D").reparent(self)
        selected_part.show()

func _on_warn_timer_timeout() -> void:
    can_move = true
    UiManager.emit_signal("warning_withdrawn", instance_id)

