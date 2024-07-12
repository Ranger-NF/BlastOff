extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var cloud_cluster_node: Node2D = $CloudCluster

var is_in_transition: bool = false
var default_viewport_size: Vector2

func _ready() -> void:
    default_viewport_size.x = ProjectSettings.get_setting("display/window/size/viewport_width")
    default_viewport_size.y = ProjectSettings.get_setting("display/window/size/viewport_height")

    UiManager.show_transition.connect(begin_transition)
    UiManager.remove_transition.connect(end_transition)
    cloud_cluster_node.hide()

func begin_transition() -> void:
    cloud_cluster_node.show()
    cloud_cluster_node.scale.x = GameManager.game_screen_size.x / default_viewport_size.x
    cloud_cluster_node.scale.y = GameManager.game_screen_size.y / default_viewport_size.y

    if not is_in_transition:
        is_in_transition = true
        anim_player.play("move_in")

        await anim_player.animation_finished

        UiManager.emit_signal("entered_transition")

func end_transition() -> void:
    if is_in_transition:
        if anim_player.is_playing():
            await anim_player.animation_finished
        is_in_transition = false
        anim_player.play("move_out")

        await anim_player.animation_finished
        cloud_cluster_node.hide()
