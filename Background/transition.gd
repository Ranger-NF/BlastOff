extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var is_in_transition: bool = false

func _ready() -> void:
    UiManager.show_transition.connect(begin_transition)
    UiManager.remove_transition.connect(end_transition)

func begin_transition() -> void:
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
