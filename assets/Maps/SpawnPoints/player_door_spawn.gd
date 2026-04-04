extends Marker2D
class_name PlayerDoorSpawn

## The delta the player moves when spawned (in cells).
@export var delta_move_on_entry : Vector2i = Vector2i(2,0)
@export var base_map : BaseMap

@onready var door_sprite : AnimatedSprite2DDoor = $AnimatedSprite2DDoor
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var player : BaseCharacter

func spawn(player_idx : int) -> Player:
	var move_action = CombatAction.create_move_action(5)
	# Todo: .merge() Dictionaries if needed here

	var relative_pos = get_parent().to_local(position)   
	var relative_cell = MapHelpers.pixel_to_cell(relative_pos)
	player = Player.create(base_map, player_idx, 3, relative_cell , move_action)
	
	base_map.add_child(player)
	
	player.position = relative_pos
	animation_player.play("OpenDoor")
	await animation_player.animation_finished
	
	door_sprite.play_close_door()
	return player
	
func move_player():
	player.move_delta(delta_move_on_entry)
