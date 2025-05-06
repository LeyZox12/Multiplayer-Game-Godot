extends Node

@onready var game_manager = get_tree().root.get_node("GameManager")
@onready var CAMERA = $"Camera"


func _ready() -> void:
	process_priority = 1
	$"Table".build(Vector2(6, 5), 128, Vector2(100, 100))
	CAMERA.move_to($"Table".get_center(), 50.0)
	print($"Table".get_center())
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
