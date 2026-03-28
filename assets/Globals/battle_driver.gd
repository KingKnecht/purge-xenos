extends Node
class_name BattleDriver

@export var Players : Array[BaseCharacter] = []
@export var Enemies : Array[BaseCharacter] = []

enum GroupTypes {
	PLAYERS,
	ENEMIES
}

signal battle_won(who : GroupTypes)

var current_group_type : GroupTypes = GroupTypes.PLAYERS
var current_group : Array[BaseCharacter]
var entities_started_turn : Array[BaseCharacter]
var is_battle_running = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_turn()
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_turn() -> void:
	match current_group_type:
		GroupTypes.PLAYERS: 
			current_group = Players
		GroupTypes.ENEMIES: 
			current_group = Enemies
		_: push_error("Unkown type")
		
	for entity in current_group:
		entity.start_turn()
		entities_started_turn.append(entity)

func on_entity_died(entity : BaseCharacter) -> void :
	Enemies.erase(entity)
	if Enemies.size() == 0:
		is_battle_running = false
		battle_won.emit(GroupTypes.PLAYERS)
	
	Players.erase(entity)
	if Players.size() == 0:
		is_battle_running = false
		battle_won.emit(GroupTypes.ENEMIES)
		
func on_entity_finished_turn(entity : BaseCharacter) -> void :
	entities_started_turn.erase(entity)
	
	if entities_started_turn.size() == 0:
		match current_group_type:
			GroupTypes.PLAYERS: 
				current_group_type = GroupTypes.ENEMIES
			GroupTypes.ENEMIES: 
				current_group_type = GroupTypes.PLAYERS
	
	start_turn()
	
