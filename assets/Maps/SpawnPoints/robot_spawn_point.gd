extends Marker2D
class_name EnemySpawnPoint

@export var base_map : BaseMap

var robot : Robot

func spawn() -> BaseCharacter:
	var relative_pos = get_parent().to_local(position)   
	var relative_cell = MapHelpers.pixel_to_cell(relative_pos)
	robot = Robot.create(base_map,3,relative_cell)
	base_map.add_child(robot)
	robot.position = relative_pos
	return robot
