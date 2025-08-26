extends Node2D

@onready var pet = $Pet
@onready var ui = $UI
@onready var camera = $Camera2D

func _ready():
	camera.make_current()
	pet.initialize()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pet.set_target_position(get_global_mouse_position())
