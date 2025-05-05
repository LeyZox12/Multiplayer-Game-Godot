extends Camera2D

var target: Vector2
var smooth_value: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir = target - position
	var move = dir / smooth_value
	position += move
	
	

func go_to(target: Vector2):
	position = target

func move_to(target: Vector2, smooth_value: float):
	self.target = target
	self.smooth_value = smooth_value
