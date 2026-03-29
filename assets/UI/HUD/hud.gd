extends CanvasLayer

@export var Player : BaseCharacter

signal player_turn_end(player : BaseCharacter)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_btn_end_turn_pressed() -> void:
	if Player == null:
		push_error("Player is not set")
		return
	player_turn_end.emit(Player)
