extends CanvasLayer

@export var Player : BaseCharacter

signal player_turn_end(player : BaseCharacter)

func _on_btn_end_turn_pressed() -> void:
	if Player == null:
		push_error("Player is not set")
		return
	player_turn_end.emit(Player)
