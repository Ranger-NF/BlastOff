extends Node

signal preview_color(color_texture: Texture)
signal preview_sticker(sticker_texture: Texture)

signal requested_skin_updation
signal ordered_skin_reload(color: Texture, texture: Texture)

signal bought_new_skin(skin_type: int)

const ROCKET_COLOR_DIR: String = "res://Player/Custom/Colors/"
const ROCKET_TEXTURE_DIR: String = "res://Player/Custom/Textures/"

const SKIN_DATA_FILE: String = "res://Data/skin_data.json"

var skin_data_dict: Dictionary
var available_color_ids: Array[int] = []
var available_texture_ids: Array[int] = []

var current_skin_textures: Dictionary = {}

enum SKIN_TYPES {
    NONE,
    PAINT,
    STICKER,
}

func _ready() -> void:
    _reload_skin_data()

    self.requested_skin_updation.connect(_get_current_skin_texture)

    _get_current_skin_texture()

func _get_current_skin_texture() -> void:
    current_skin_textures.color = get_color(DataManager.gameplay.current_color)
    current_skin_textures.texture = get_texture(DataManager.gameplay.current_texture)

    self.emit_signal("ordered_skin_reload", current_skin_textures.color, current_skin_textures.texture)


func get_skin_data(skin_id: int, skin_type: int = SKIN_TYPES.NONE) -> Dictionary:
    if skin_type == SKIN_TYPES.NONE:
        if skin_id > 99: ## Works for now as paints have values from 100 to 999, and stickers have 10 to 99
            skin_type = SKIN_TYPES.PAINT
        else:
            skin_type = SKIN_TYPES.STICKER

    var matched_textures: Array

    match skin_type:
        SKIN_TYPES.PAINT:
            matched_textures = skin_data_dict.colors.filter(func (each_entry): return each_entry.id == skin_id)
        SKIN_TYPES.STICKER:
            matched_textures = skin_data_dict.textures.filter(func (each_entry): return each_entry.id == skin_id)

    if matched_textures.is_empty():
        return {}
    else:
        return matched_textures.front()

func get_color(color_id: int = 100) -> Texture:
    #var matched_colors: Array = skin_data_dict.colors.filter(func (each_entry): return each_entry.id == color_id)
    var skin_data: Dictionary = get_skin_data(color_id, SKIN_TYPES.PAINT)

    if skin_data.is_empty():
        return ResourceLoader.load(ROCKET_COLOR_DIR + "base.svg")

    return ResourceLoader.load(ROCKET_COLOR_DIR + skin_data.filename)

func get_texture(sticker_id: int = 10) -> Texture:
    var skin_data: Dictionary = get_skin_data(sticker_id, SKIN_TYPES.STICKER)

    if skin_data.is_empty():
        return ResourceLoader.load(ROCKET_TEXTURE_DIR + "base.svg")

    return ResourceLoader.load(ROCKET_TEXTURE_DIR + skin_data.filename)

func get_cost(skin_id: int, skin_type: int = SKIN_TYPES.NONE) -> int:
    var skin_data = get_skin_data(skin_id, skin_type)

    var skin_cost: int = 100000

    if not skin_data.is_empty():
        skin_cost = skin_data.cost

    return skin_cost

func _reload_skin_data() -> void:
    var file_content: String = FileAccess.get_file_as_string(SKIN_DATA_FILE)
    skin_data_dict = JSON.parse_string(file_content)

    for each_color_entry in skin_data_dict.colors:
        available_color_ids.append(int(each_color_entry.id))

    for each_texture_entry in skin_data_dict.textures:
        available_texture_ids.append(int(each_texture_entry.id))
