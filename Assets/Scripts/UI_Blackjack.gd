extends Control

var last_bet:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not is_multiplayer_authority(): return
	$"Blackjack/Slider".visible = !$"../../".is_ready
	#$money.text = "$:" + str(get_parent().money)
	var text = "Bet:"
	if $"Blackjack/Slider".value == 1.0:
		text += "ALL IN!"
	else:
		text += str($"Blackjack/Slider".value * $"../../".money)
	$"Blackjack/Slider/Label".text = text
	pass

func get_bet() -> int:
	if $"Blackjack/Slider".visible:
		last_bet = $"Blackjack/Slider".value * $"../../".money
	return last_bet
