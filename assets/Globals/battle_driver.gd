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
	#for character in Players:
		#character.turn_ended.connect(on_turn_ended)
	
	#for character in Enemies:
		#character.turn_ended.connect(on_turn_ended)
	
	match current_group_type:
		GroupTypes.PLAYERS: 
			current_group = Players
		GroupTypes.ENEMIES: 
			current_group = Enemies
		_: push_error("Unkown type")
	
	start_battle()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_battle() -> void:
	while is_battle_running:
		await next_round()

func next_round() -> void:
			
	for entity in current_group:
		current_character = entity
		
		entity.start_turn.call_deferred() # Make sure we don't miss the awaited signal in the next line.
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
			
#func on_turn_ended(character : BaseCharacter) -> void :
	#
	##print("Character (%d) turn ended" % character.PlayerIndex)
	#
	#characters_ended_turn.append(character)
	#
	#if characters_started_turn.size() > 0 && characters_ended_turn.size() == characters_started_turn.size():
		## All characters of a group have ended their turn
		#characters_started_turn.clear()
		#characters_ended_turn.clear()
		#
		#match current_group_type:
			#GroupTypes.PLAYERS: 
				#current_group_type = GroupTypes.ENEMIES
			#GroupTypes.ENEMIES: 
				#current_group_type = GroupTypes.PLAYERS
		#
		#current_character = null		
		#
		#next_turn()
	
func on_character_died(character : BaseCharacter) -> void :
	
	Enemies.erase(character)
		
	if Enemies.size() == 0:
		is_battle_running = false
		battle_won.emit(GroupTypes.PLAYERS)
	
	Players.erase(character)
	if Players.size() == 0:
		is_battle_running = false
		battle_won.emit(GroupTypes.ENEMIES)
