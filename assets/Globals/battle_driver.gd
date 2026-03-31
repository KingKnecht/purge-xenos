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
var current_character : BaseCharacter

var is_battle_running = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	match current_group_type:
		GroupTypes.PLAYERS: 
			current_group = Players
		GroupTypes.ENEMIES: 
			current_group = Enemies
		_: push_error("Unkown type")
	
	for entity in Players + Enemies:
		entity.action_on_cell_requested.connect(excecute_action_on_cell)
		entity.action_on_character_requested.connect(excecute_action_on_character)
	
	SignalBus.battle_started.connect(start_battle)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_battle() -> void:
	while is_battle_running:
		await next_round()

func next_round() -> void:
			
	for entity in current_group:
		current_character = entity
		
		entity.start_turn() # Make sure we don't miss the awaited signal in the next line.
		var character = await entity.turn_ended
		print("Character (%d) turn ended" % character.PlayerIndex)
	
	# Switch groups
	match current_group_type:
		GroupTypes.PLAYERS: 
			current_group_type = GroupTypes.ENEMIES
			current_group = Enemies
		GroupTypes.ENEMIES: 
			current_group_type = GroupTypes.PLAYERS
			current_group = Players

func excecute_action_on_character(fromCharacter : BaseCharacter, action : CombatAction, target : BaseCharacter):
	if fromCharacter != current_character:
		return
	print("Character (%d) requested action '%s' on character '%d'" % [fromCharacter.PlayerIndex, action.display_name, target.PlayerIndex])
	
func excecute_action_on_cell(fromCharacter : BaseCharacter,action: CombatAction,  target : Vector2i):
	if fromCharacter != current_character:
		return
	print("Character (%d) requested action '%s' on cell '%s'" % [fromCharacter.PlayerIndex, action.display_name, str(target)])
	
	#todo: if is 'move'
	fromCharacter._on_move_requested(target)
		
func on_character_died(character : BaseCharacter) -> void :
	
	Enemies.erase(character)
	if Enemies.size() == 0:
		is_battle_running = false
		battle_won.emit(GroupTypes.PLAYERS)
	
	Players.erase(character)
	if Players.size() == 0:
		is_battle_running = false
		battle_won.emit(GroupTypes.ENEMIES)
