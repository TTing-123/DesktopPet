extends Control

@onready var pet_system: Node2D = $"../PetSystem"
@onready var dialog_box: Control = $"../DialogBox"

var dragging: bool = false
var drag_start: Vector2i
var mouse_down_time: float = 0.0
var is_chating: bool = false

func _ready() -> void:
	pet_system.show()
	dialog_box.hide()
	dialog_box.exited.connect(_on_dialog_box_exited)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 记录鼠标按下时间
			mouse_down_time = Time.get_ticks_msec()
			dragging = false
		else:
			# 检查是否是单击（短于100毫秒）
			if Time.get_ticks_msec() - mouse_down_time < 100 and not dragging and is_chating == false:
				pet_system.hide()
				dialog_box.show()
				print("进入聊天框")
				is_chating = true
			dragging = false
		
		get_viewport().set_input_as_handled()
	
	elif event is InputEventMouseMotion:
		# 如果鼠标按下超过100毫秒，开始拖拽
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not dragging:
			if Time.get_ticks_msec() - mouse_down_time >= 100:
				dragging = true
				drag_start = DisplayServer.mouse_get_position() - DisplayServer.window_get_position()
		
		if dragging:
			var new_pos = DisplayServer.mouse_get_position() - drag_start
			DisplayServer.window_set_position(new_pos)
			get_viewport().set_input_as_handled()

func _on_dialog_box_exited():
	dialog_box.hide()
	pet_system.show()
	print("退出聊天框")
	is_chating = false
