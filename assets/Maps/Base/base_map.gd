extends Node2D
class_name BaseMap

@export 
var pathfind: Pathfind

@onready var map_floor: MapFloor = $Floor
@onready var map_walls: Node2D = $Walls
@onready var map_interior: Node2D = $Interior

func _ready():
	# sets the current map (self) at the cursor manager
	SignalBus.main_init_finished.connect(func(): 
		SignalBus.map_initialized.emit(self))

func is_tile_walk_selectable(pos: Vector2i) -> bool:
	return pathfind.astar_grid.region.has_point(pos) and not pathfind.astar_grid.is_point_solid(pos)

## Unblocks the from field temporarily
func get_astar_path(from : Vector2i, to : Vector2i, partial_path : bool = false) -> Array[Vector2i]:
	pathfind.astar_grid.set_point_solid(from, false)
	var path = pathfind.astar_grid.get_id_path(from, to, partial_path)
	pathfind.astar_grid.set_point_solid(from, true)
	return path

## Returns the rect of the floor in pixel world coordinates.
func get_used_rect() -> Rect2:
	var used_rect : Rect2i = map_floor.get_used_rect()
	# Get the top-left position in world coordinates
	var world_position = map_floor.map_to_local(used_rect.position)
	# Get the size in world coordinates (pixels)
	var world_size = map_floor.map_to_local(used_rect.size)
	
	return Rect2(world_position, world_size)


func get_cells_on_line(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	#implements bresenham algorithm
	var cells: Array[Vector2i] = []
	var dx = abs(to_cell.x - from_cell.x)
	var dy = abs(to_cell.y - from_cell.y)
	var sx = 1 if from_cell.x < to_cell.x else -1
	var sy = 1 if from_cell.y < to_cell.y else -1
	var err = dx - dy
	var x = from_cell.x
	var y = from_cell.y
	while true:
		cells.append(Vector2i(x, y))
		if x == to_cell.x and y == to_cell.y:
			break
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy
	return cells
										
func segment_intersects_rect(from_point: Vector2, to_point: Vector2, rect: Rect2) -> bool:
	if rect.has_point(from_point) or rect.has_point(to_point):
		return true

	var a = rect.position
	var b = a + Vector2(rect.size.x, 0)
	var c = a + rect.size
	var d = a + Vector2(0, rect.size.y)

	if Geometry2D.segment_intersects_segment(from_point, to_point, a, b):
		return true
	if Geometry2D.segment_intersects_segment(from_point, to_point, b, c):
		return true
	if Geometry2D.segment_intersects_segment(from_point, to_point, c, d):
		return true
	if Geometry2D.segment_intersects_segment(from_point, to_point, d, a):
		return true

	return false

# los = line of sight
func get_los_to_enemies(from : Vector2i, enemy_group_name : String) -> Array:
	var result = []
	for child in self.get_children(): 
		var c = child as BaseCharacter
		if c == null:
			continue
		if c.get_groups().has(enemy_group_name):
			var los = get_line_of_sight(from, c.current_cell, true, true)
			if los.size() > 0:
				result.append(los)
	return result

func get_line_of_sight(from_cell: Vector2i,
 to_cell: Vector2i,
 ignore_solid_from: bool,
 ignore_solid_to: bool) -> Array[Vector2]:
		
	var cells = get_cells_on_line(from_cell, to_cell)
	for cell in cells:
		if pathfind.astar_grid.is_point_solid(cell) and not (
					(cell == from_cell and ignore_solid_from) 
					or (cell == to_cell and ignore_solid_to)):	
			return []
	return [MapHelpers.cell_to_pixel(from_cell), MapHelpers.cell_to_pixel(to_cell)]
