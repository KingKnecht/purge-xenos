@tool extends Node

@export var cell_size : Vector2i = Vector2i(32,32)

## The extents of the playable area. This property is intended for editor use and should not change
## during gameplay, as that would change how [Pathfinder] indices are calculated.
@export var extents: = Rect2i(0, 0, 10, 10):
	set(value):
		extents = value
		
		# Ensure that the boundary size is greater than 0.
		extents.size.x = maxi(extents.size.x, 1)
		extents.size.y = maxi(extents.size.y, 1)
		##extents_changed.emit()


## An invalid cell is not part of the gameboard. Note that this requires positive
## [member boundaries].
const INVALID_CELL: = Vector2i(-1, -1)

## An invalid index is not found on the gameboard. Note that this requires positive 
const INVALID_INDEX: = -1

## Convert cell coordinates to pixel coordinates.
func cell_to_pixel(cell_coordinates: Vector2i) -> Vector2:
	return Vector2(cell_coordinates * cell_size) + (cell_size / 2.0)
	

## Convert pixel coordinates to cell coordinates.
func pixel_to_cell(pixel_coordinates: Vector2) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(
		floori(pixel_coordinates.x / cell_size.x),
		floori(pixel_coordinates.y / cell_size.y)
	)
	

## Convert cell coordinates to an index unique to those coordinates.
## [br][br][b]Note:[/b] cell coordinates outside the [member extents] will return
## [constant INVALID_INDEX].
func cell_to_index(cell_coordinates: Vector2i) -> int:
	if extents.has_point(cell_coordinates):
		# Negative coordinates can throw off index generation, so offset the boundary so that it's
		# top left corner is always considered Vector2i.ZERO and index 0.
		return (cell_coordinates.x-extents.position.x) \
			+ (cell_coordinates.y-extents.position.y)*extents.size.x
	return INVALID_INDEX


## Convert a unique index to cell coordinates.
## [br][br][b]Note:[/b] indices outside the gameboard [member GameboardProperties.extents] will
## return [constant INVALID_CELL].
func index_to_cell(index: int) -> Vector2i:
	@warning_ignore("integer_division")
	var cell: = Vector2i(
		index % extents.size.x + extents.position.x,
		index / extents.size.x + extents.position.y
	)

	if extents.has_point(cell):
		return cell
	return INVALID_CELL
	
	
