extends Node

@onready var game_manager = get_tree().root.get_node("GameManager")
@onready var CAMERA = $"Camera"


func _ready() -> void:
	process_priority = 1

	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:


	pass
