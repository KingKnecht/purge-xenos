class_name CombatAction
extends Resource

@export var display_name : String
@export var description : String

@export var damage : int = 0
@export var heal : int = 0
@export var movement : int = 0
@export var path : Array[Vector2i] = []
@export var cost : int = 0
@export_flags("SELF:1", "GROUP_MEMBERS:2", "OPPONENTS:4", "CELL:8") var valid_target_flags: int = 0

const MOVE_ACTION_STR : String = "res://assets/CombatScripts/move.tres"

enum ActionType{
	NONE,
	HEAL,
	MEGA_PEW_PEW,
	MOVE,
	PEW_PEW
}

enum ValidTargetFlags {
	NONE = 0,
	SELF = 1 << 0,
	GROUP_MEMBERS = 1 << 1,
	OPPONENTS = 1 << 2,
	CELL = 1 << 3,
}

static func create_move_action(movement : int) -> Dictionary[ActionType, CombatAction]:
	var move = load(MOVE_ACTION_STR).duplicate()
	move.display_name = "Move"
	move.movement = movement
	return  {ActionType : move}
