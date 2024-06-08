extends Node

signal warning_announced(x_position: float, warning_id: int) # For showing a warning sign when heavy objects are falling
signal warning_withdrawn(warning_id: int)

signal skipped_to_main_menu
signal opened_settings
signal opened_credits

signal first_startup
signal show_tutorial

#MENU_LEVEL.MAIN is index 1 not zero so keep that in mind if you change to an array
enum MENU_IDS {
        NONE,
        MAIN_MENU,
        SETTINGS,
        CREDITS,
        CONTROLS,
        INGAME_UI,
        GAME_OVER,
    }

var menus = {
    MENU_IDS.MAIN_MENU : preload("res://UI/main_menu.tscn").instantiate(),
    MENU_IDS.SETTINGS : preload("res://UI/settings.tscn").instantiate(),
    MENU_IDS.CREDITS : preload("res://UI/credits.tscn").instantiate(),
    MENU_IDS.INGAME_UI : preload("res://UI/ingame_ui.tscn").instantiate(),
    MENU_IDS.GAME_OVER : preload("res://UI/game_over.tscn").instantiate(),
    MENU_IDS.CONTROLS: preload("res://UI/controls.tscn").instantiate(),
}
var need_tutorial: bool = false

var main_scene: Node
var current_menu: Node

func _ready() -> void:
    self.first_startup.connect(func () -> void: need_tutorial = true)
    GameManager.game_started.connect(_check_tutorial_need)

    self.skipped_to_main_menu.connect(spawn_menu.bind(MENU_IDS.MAIN_MENU))
    self.opened_settings.connect(spawn_menu.bind(MENU_IDS.SETTINGS))
    self.opened_credits.connect(spawn_menu.bind(MENU_IDS.CREDITS))

    GameManager.game_started.connect(_spawn_ingame_uis)
    GameManager.game_over.connect(spawn_menu.bind(MENU_IDS.GAME_OVER))


func spawn_menu(menu_id: int):
    call_deferred("_deferred_load_menu", menu_id)

func _spawn_ingame_uis():
    main_scene.add_child(menus[MENU_IDS.CONTROLS])
    spawn_menu(MENU_IDS.INGAME_UI)

func _deferred_load_menu(menu_id: int):
    if not main_scene:
        push_error("Main scene not set in UiManager")
    #replace the current menus instance with the new ones
    current_menu = menus[menu_id]

    var menu_container = main_scene.find_child("Menu", false, false)

    if not menu_container:
        var menu_node = Node.new()
        menu_node.set_name("Menu")
        main_scene.add_child(menu_node)
        menu_container = menu_node

    #clear the current menu item/s
    for location in menu_container.get_children():
        menu_container.remove_child(location)

    #add our selected menu
    menu_container.add_child(current_menu)

func _check_tutorial_need() -> void:
    if need_tutorial:
        emit_signal("show_tutorial")
        need_tutorial = false
