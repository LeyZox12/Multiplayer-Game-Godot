extends Label

var vel: Vector2
var rotation_vel: float
var G = 9.8
var should_fall = true
const ROTATION_POWER = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pivot_offset = size / 2.0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position.y > 1000:
		should_fall = false
	
	if should_fall:
		rotation += rotation_vel * delta
		position += vel * delta
	
		vel.y += G
		#vel += Vector2(cos(deg_to_rad(rotation+90)) * ROTATION_POWER, sin(deg_to_rad(rotation+90) * ROTATION_POWER))
	pass
