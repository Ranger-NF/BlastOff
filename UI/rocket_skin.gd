extends Control

@onready var color_overlay_node: TextureRect = $Color
@onready var texture_overlay_node: TextureRect = $Texture

func _update_current_skin(_node: Node = null) -> void:
    color_overlay_node.texture = SkinManager.current_skin_textures.color
    texture_overlay_node.texture = SkinManager.current_skin_textures.texture

    #current_color_index = SkinManager.available_color_ids.find(DataManager.gameplay.current_color)
    #current_texture_index = SkinManager.available_texture_ids.find(DataManager.gameplay.current_texture)


func
