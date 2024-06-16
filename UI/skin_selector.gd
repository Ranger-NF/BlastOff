extends Control

signal back_button_pressed
signal refresh_ui(skin_type: int)

@onready var paint_cost_label: Button = $MarginContainer/VBoxContainer/TabContainer/Paint/VBoxContainer/HBoxContainer3/BuyButton/CenterContainer/MarginContainer/VBoxContainer/MarginContainer/PaintCost
@onready var sticker_cost_label: Button = $MarginContainer/VBoxContainer/TabContainer/Stickers/VBoxContainer/HBoxContainer3/BuyButton/CenterContainer/MarginContainer/VBoxContainer/MarginContainer/StickerCost

enum TABS {
    PAINT,
    STICKER,
}

var is_in_initial_setup:bool = true
var current_color_index: int # Useful for cycling through colors
var current_texture_index: int

func _ready() -> void:
    self.back_button_pressed.connect(_on_back_button_pressed)
    self.child_entered_tree.connect(_update_current_skin)
    self.refresh_ui.connect(_on_refresh)
    _update_current_skin()

func _update_current_skin(_node: Node = null) -> void:
    SkinManager.emit_signal("requested_skin_updation")
    current_color_index = SkinManager.available_color_ids.find(DataManager.gameplay.current_color)
    current_texture_index = SkinManager.available_texture_ids.find(DataManager.gameplay.current_texture)

func _on_back_button_pressed() -> void:
    UiManager.emit_signal("skipped_to_main_menu")

func _on_next_button_pressed(tab: int) -> void:
    if tab == TABS.PAINT:
        current_color_index = (current_color_index + 1) % SkinManager.available_color_ids.size()
    elif tab == TABS.STICKER:
        current_texture_index = (current_texture_index + 1) % SkinManager.available_texture_ids.size()

    emit_signal("refresh_ui", tab)

func _on_previous_button_pressed(tab: int) -> void:
    if tab == TABS.PAINT:
        current_color_index = (current_color_index - 1) % SkinManager.available_color_ids.size()
    elif tab == TABS.STICKER:
        current_texture_index = (current_texture_index - 1) % SkinManager.available_texture_ids.size()

    emit_signal("refresh_ui", tab)


func _on_buy_button_pressed(tab: int) -> void:
    if tab == TABS.PAINT:
        var selected_paint_id: int = SkinManager.available_color_ids[current_color_index]
        var transaction_status = _process_payment(selected_paint_id)

        if transaction_status:
            DataManager.gameplay.current_color = SkinManager.available_color_ids[current_color_index]

    elif tab == TABS.STICKER:
        var selected_sticker_id: int = SkinManager.available_texture_ids[current_texture_index]
        var transaction_status = _process_payment(selected_sticker_id)

        if transaction_status:
            DataManager.gameplay.current_texture = SkinManager.available_texture_ids[current_texture_index]

    SkinManager.emit_signal("requested_skin_updation")
    DataManager.emit_signal("save_triggered")

func _process_payment(skin_id: int) -> bool:
    var current_star_count: int = DataManager.gameplay.total_stars

    var skin_cost: int = SkinManager.get_cost(skin_id)

    if skin_cost <= current_star_count:
        StatManager.emit_signal("star_count_changed", -1 * skin_cost)
        return true
    else:
        return false

func _on_refresh(skin_type: int) -> void:
    if is_in_initial_setup:
        await self.ready
        is_in_initial_setup = false

    SkinManager.emit_signal("requested_skin_updation")

    if skin_type == TABS.PAINT:
        SkinManager.emit_signal("preview_color", SkinManager.get_color(SkinManager.available_color_ids[current_color_index]))
        paint_cost_label.text = str(SkinManager.get_cost(SkinManager.available_color_ids[current_color_index]))
    elif skin_type == TABS.STICKER:
        SkinManager.emit_signal("preview_sticker", SkinManager.get_texture(SkinManager.available_texture_ids[current_texture_index]))
        sticker_cost_label.text = str(SkinManager.get_cost(SkinManager.available_texture_ids[current_texture_index]))
