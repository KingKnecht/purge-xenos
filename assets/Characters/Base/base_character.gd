@tool extends Marker2D
class_name BaseCharacter

@export var current_cell : Vector2i = Vector2i(5,5)
@export var map_interface: MapInterface
@export var cursor_manager: CursorManager
@export var Direction : Directions.Points = Directions.Points.EAST
## Use negative values for enemies
@export var PlayerIndex : int = 0

signal turn_ended(character : BaseCharacter)

var is_player : bool:
	get:
		return PlayerIndex > -1
	 
const DIRECTION_SUFFIXES: = {
	Directions.Points.NORTH: "_N",
	Directions.Points.EAST: "_E",
	Directions.Points.SOUTH: "_S",
	Directions.Points.WEST: "_W",
}
var is_moving = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if is_player:
		assert(is_instance_valid(cursor_manager), "CursorManager not set for Player: %d" % PlayerIndex)
		cursor_manager.move_requested.connect(_on_move_requested)
			
	var current_pixel_pos = MapHelpers.cell_to_pixel(current_cell)
	self.position = current_pixel_pos
	map_interface.pathfind.add_character(current_cell)
	

func play() -> void: 
	var sequence_suffix: String = DIRECTION_SUFFIXES.get(Direction, "_E") 
	if is_moving:
		$AnimatedSprite2D.play("walk_no_weapon" + sequence_suffix)
	else:
		$AnimatedSprite2D.play("idle_no_weapon" + sequence_suffix)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		position = MapHelpers.cell_to_pixel(current_cell)
	play()
	
func _on_move_requested(target: Vector2i):
	
	if is_moving:
		return
		
	is_moving = true
		
	var old_pos = current_cell
	map_interface.pathfind.remove_character(old_pos)
	
	var path = map_interface.pathfind.astar_grid.get_id_path(old_pos, target)

	map_interface.pathfind.add_character(target)
	
	if path.size() == 0:
		is_moving = false
		return
	
	calc_direction(path[0], path[1])
	
	var move_tween: Tween = create_tween()
	
	move_tween.step_finished.connect(func(idx : int): 
		if idx < path.size() - 2:
			calc_direction(path[idx + 1], path[idx + 2])	
		else:
			calc_direction(path[idx - 1], path[idx])	
		)
			
	for step_index in range(1, path.size()):
		var step = Vector2i(path[step_index])
		var pixel_step = MapHelpers.cell_to_pixel(step)	
		move_tween.tween_property(self, "position", pixel_step, 0.2)
	
	move_tween.tween_callback(func(): is_moving = false)
	
	current_cell = target

func calc_direction(from : Vector2i, to: Vector2i):
	Direction = Directions.vector_to_direction(to - from)
	
func start_turn():
	print("Character (%d) turn started" % PlayerIndex)
	if is_player:
		# do stuff
		var wait_time = randf_range(1.0, 3.5)
		await get_tree().create_timer(wait_time).timeout
		end_turn()
	else:
		# do AI stuff
		var wait_time = randf_range(1.0, 3.5)
		await get_tree().create_timer(wait_time).timeout
		end_turn()
	
func end_turn():
	turn_ended.emit(self)
