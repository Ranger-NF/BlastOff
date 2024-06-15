extends Node


signal requested_skin_updation
signal skin_updated(color: Texture, texture: Texture)

const ROCKET_COLOR_DIR: String = "res://Player/Custom/Colors/"
const ROCKET_TEXTURE_DIR: String = "res://Player/Custom/Textures/"

const SKIN_DATA_FILE: String = "res://Data/skin_data.json"

var skin_data_dict: Dictionary
var available_color_ids: Array[int] = []
var available_texture_ids: Array[int] = []

var current_skin_textures: Dictionary = {}

func _ready() -> void:
    _reload_skin_data()

    self.requested_skin_updation.connect(_get_current_skin_texture)
    self.skin_updated.connect(_on_skin_updation)

    _get_current_skin_texture()

func _get_current_skin_texture() -> void:
    var color_sprite: Texture = get_color(DataManager.gameplay.current_color)
    var texture_sprite: Texture = get_texture(DataManager.gameplay.current_texture)

    self.emit_signal("skin_updated", color_sprite, texture_sprite)

func _on_skin_updation(color_sprite: Texture, texture_sprite: Texture) -> void:
    current_skin_textures.color = color_sprite
    current_skin_textures.texture = texture_sprite

func get_color(color_id: int = 100) -> Texture:
    var matched_colors: Array = skin_data_dict.colors.filter(func (each_entry): return each_entry.id == color_id)

    if matched_colors.is_empty():
        return load(ROCKET_COLOR_DIR + "base.svg")

    return load(ROCKET_COLOR_DIR + matched_colors.front().filename)

func get_texture(texture_id: int = 10) -> Texture:
    var matched_textures: Array = skin_data_dict.textures.filter(func (each_entry): return each_entry.id == texture_id)

    if matched_textures.is_empty():
        return load(ROCKET_TEXTURE_DIR + "base.svg")

    return load(ROCKET_TEXTURE_DIR + matched_textures.front().filename)

func _reload_skin_data() -> void:
    var file_content: String = FileAccess.get_file_as_string(SKIN_DATA_FILE)
    skin_data_dict = JSON.parse_string(file_content)

    for each_color_entry in skin_data_dict.colors:
        available_color_ids.append(int(each_color_entry.id))

    for each_texture_entry in skin_data_dict.textures:
        available_texture_ids.append(int(each_texture_entry.id))
