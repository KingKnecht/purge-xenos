@tool extends Marker2D
class_name BaseCharacter

@export var current_cell : Vector2i = Vector2i(5,5)
@export var map_interface: MapInterface

var is_moving = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_interface.floor.move_requested.connect(_on_move_requested)
	var current_pixel_pos = MapHelpers.cell_to_pixel(current_cell)
	self.position = current_pixel_pos
	map_interface.pathfind.add_character(current_cell)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
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
		
	
	var move_tween: Tween = create_tween()
	
	var path_length = path.size() - 1
	for step_index in range(1, path.size()):
		var step = path[step_index]
		var pixel_step = MapHelpers.cell_to_pixel(step)
		move_tween.tween_property(self, "position", pixel_step, 0.2)
		
	move_tween.tween_callback(func(): is_moving = false)
	
	current_cell = target

	
