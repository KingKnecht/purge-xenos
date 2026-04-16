extends BaseCharacter
class_name Player

const PLAYER_SCENE : PackedScene = preload("res://assets/Characters/Base/Players/Player.tscn")

var player_index : int
var is_executing: bool = false

func _ready() -> void:
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var sequence_suffix: String = DIRECTION_SUFFIXES.get(Direction, "_E") 
	if is_moving:
		current_cell = MapHelpers.pixel_to_cell(position)
		sprite.play("walk_no_weapon" + sequence_suffix)
	else:
		sprite.play("idle_no_weapon" + sequence_suffix)

## Creates an instance of a pre-configured Player
static func create(base_map : BaseMap,
	 player_index : int,
	 max_action_count : int,
	 max_health : int,
	 current_cell : Vector2i,
	 combat_actions : Dictionary[CombatAction.ActionType, CombatAction] ) -> BaseCharacter:
		
		var player =  PLAYER_SCENE.instantiate() as Player		
		player.combat_actions = combat_actions
		player.base_map = base_map
		player.player_index = player_index
		player.max_action_count = max_action_count
		player.max_health = max_health
		player.current_cell = current_cell
		return player

func start_turn():
	Log.debug("Turn started for '%s'" % [self])
	action_count = max_action_count
	
func execute_action(target: Vector2i):
	if is_executing:
		return
	if selected_action.needs_line_of_sight:
		var los = base_map.get_line_of_sight(current_cell, target, true, true, selected_action.weapon_range)
		if los.is_empty():
			return
	is_executing = true
	SignalBus.before_action_executed.emit(self, selected_action)
	if selected_action.movement > 0:
		selected_action.path = get_preferred_path_to(target)
	if selected_action.needs_line_of_sight:
		selected_action.targeted_cells = [target]
	var executor = ActionExecutor.new([selected_action])
	await executor.execute(self)
	is_executing = false
