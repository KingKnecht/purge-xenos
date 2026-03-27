extends TileMapLayer
class_name MapFloor

signal move_requested(target: Vector2i)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	##print(get_local_mouse_position())
	(material as ShaderMaterial).set_shader_parameter("mouse_position", MapHelpers.cell_to_pixel(MapHelpers.pixel_to_cell(get_local_mouse_position())) )

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.button_mask & MouseButton.MOUSE_BUTTON_LEFT:
			var mouse_pos = get_local_mouse_position()
			var cell = MapHelpers.pixel_to_cell(mouse_pos)
			
			move_requested.emit(cell)
