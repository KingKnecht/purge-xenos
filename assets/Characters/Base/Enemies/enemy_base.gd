extends BaseCharacter
class_name EnemyBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.pre_begin_turn.connect(_on_pre_begin_turn)

func _on_pre_begin_turn():
	pass
