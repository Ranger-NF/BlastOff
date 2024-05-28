extends Node

signal warning_announced(x_position: float, warning_id: int) # For showing a warning sign when heavy objects are falling
signal warning_withdrawn(warning_id: int)

signal skipped_to_main_menu
