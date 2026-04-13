extends ColorRect
class_name ActionPointsBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make shader unique
	material = material.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_points(value : int):
	material.set_shader_parameter("discrete_fill_amount", value)

func set_max_points(value : int):
	material.set_shader_parameter("segment_count", value)
