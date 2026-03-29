class_name EnumHelpers
extends RefCounted

static func has_flag(all: int, flag: int) -> bool:
	return (all & flag) != 0
