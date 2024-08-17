extends Control

@onready var paint_overlay_node: TextureRect = $Paint
@onready var sticker_overlay_node: TextureRect = $Sticker
@onready var spray_paint_particles: CPUParticles2D = $PaintSprayParticles

var current_skins: Dictionary = {}

var shine_tween: Tween

func _ready() -> void:
    SkinManager.ordered_skin_reload.connect(_update_current_skin)
    SkinManager.preview_color.connect(_preview_color)
    SkinManager.preview_sticker.connect(_preview_sticker)
    SkinManager.bought_new_skin.connect(_show_signs_of_purchase)

    SkinManager.emit_signal("requested_skin_updation")

func _update_current_skin(new_paint_texture: Texture, new_sticker_texture: Texture) -> void:
    paint_overlay_node.texture = new_paint_texture
    sticker_overlay_node.texture = new_sticker_texture

    current_skins[SkinManager.SKIN_TYPES.PAINT] = paint_overlay_node.texture
    current_skins[SkinManager.SKIN_TYPES.STICKER] = sticker_overlay_node.texture

func _show_signs_of_purchase(skin_type: int):
    if not self.is_visible_in_tree():
        return

    if skin_type == SkinManager.SKIN_TYPES.PAINT:
        _show_repaint_partcles()
    elif skin_type == SkinManager.SKIN_TYPES.STICKER:
        _make_texture_shine()

func _show_repaint_partcles() -> void:
    spray_paint_particles.position = Vector2(paint_overlay_node.position.x + paint_overlay_node.size.x / 2, paint_overlay_node.position.y +  paint_overlay_node.size.y / 2)
    spray_paint_particles.emission_sphere_radius = paint_overlay_node.size.x / 2

    spray_paint_particles.emitting = true


func _make_texture_shine():
    const SHINE_TIME: float = 0.6
    if shine_tween and shine_tween.is_valid():
        shine_tween.stop()
        shine_tween.kill()
        sticker_overlay_node.material.set_shader_parameter("shine_progress", 0.1)

    shine_tween = create_tween().set_parallel(true)
    shine_tween.tween_property(sticker_overlay_node.material, "shader_parameter/shine_progress", 0.7, SHINE_TIME/2)
    shine_tween.tween_property(sticker_overlay_node.material, "shader_parameter/shine_progress", 0.1, SHINE_TIME/2).set_delay(SHINE_TIME/2)

func _preview_color(color_texture:Texture):
    paint_overlay_node.texture = color_texture

func _preview_sticker(sticker_texture: Texture):
    sticker_overlay_node.texture = sticker_texture
