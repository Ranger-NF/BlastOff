extends Control

@onready var color_overlay_node: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer2/RocketSkin/Color
@onready var texture_overlay_node: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer2/RocketSkin/Texture

var current_color_index: int # Useful for cycling through colors
var current_texture_index: int

func _ready() -> void:
    self.child_entered_tree.connect(_update_current_skin)
    _update_current_skin()

func _update_current_skin(_node: Node = null) -> void:
    color_overlay_node.texture = SkinManager.current_skin_textures.color
    texture_overlay_node.texture = SkinManager.current_skin_textures.texture

    current_color_index = SkinManager.available_color_ids.find(DataManager.gameplay.current_color)
    current_texture_index = SkinManager.available_texture_ids.find(DataManager.gameplay.current_texture)

func _on_back_button_pressed() -> void:
    UiManager.emit_signal("skipped_to_main_menu")

func _on_next_button_pressed() -> void:
    current_color_index = (current_color_index + 1) % SkinManager.available_color_ids.size()
    color_overlay_node.texture = SkinManager.get_color(SkinManager.available_color_ids[current_color_index])

func _on_previous_button_pressed() -> void:
    current_color_index -= 1
    color_overlay_node.texture = SkinManager.get_color(SkinManager.available_color_ids[current_color_index])

func _on_buy_button_pressed() -> void:
    DataManager.gameplay.current_color = SkinManager.available_color_ids[current_color_index]
    DataManager.gameplay.current_texture = SkinManager.available_texture_ids[current_texture_index]

    SkinManager.emit_signal("requested_skin_updation")
    DataManager.emit_signal("save_triggered")
